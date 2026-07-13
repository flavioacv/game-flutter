import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/players.dart';

class RoomInfo {
  final String id;
  final String name;
  final String hostId;
  final int maxPlayers;
  final int currentPlayers;
  final DateTime createdAt;
  final String status; // 'waiting', 'playing', 'finished'

  RoomInfo({
    required this.id,
    required this.name,
    required this.hostId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.createdAt,
    required this.status,
  });

  factory RoomInfo.fromMap(String id, Map<dynamic, dynamic> map) {
    final info = map['info'] as Map<dynamic, dynamic>?;
    return RoomInfo(
      id: id,
      name: info?['name'] as String? ?? 'Sala sem nome',
      hostId: info?['host'] as String? ?? '',
      maxPlayers: info?['maxPlayers'] as int? ?? 4,
      currentPlayers: info?['currentPlayers'] as int? ?? 0,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(info?['createdAt'] as int? ?? 0),
      status: info?['status'] as String? ?? 'waiting',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'host': hostId,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status,
    };
  }
}

class MultiplayerService {
  DatabaseReference? _roomRef;
  String? currentRoomId;
  bool amIHost = false;

  DatabaseReference get _salasRef => FirebaseDatabase.instance.ref('salas');

  /// Creates a new room and returns the room ID
  Future<String> createRoom(
    String roomName,
    String hostId,
    String hostNickname,
    int maxPlayers,
  ) async {
    try {
      print('[MultiplayerService] Criando sala "$roomName" no Firebase...');

      // Generate new room ID
      final newRoomRef = _salasRef.push();
      final roomId = newRoomRef.key!;

      // Create room info
      final roomInfo = RoomInfo(
        id: roomId,
        name: roomName,
        hostId: hostId,
        maxPlayers: maxPlayers,
        currentPlayers: 0,
        createdAt: DateTime.now(),
        status: 'waiting',
      );

      // Set room data with timeout to avoid infinite loading
      await newRoomRef
          .child('info')
          .set(roomInfo.toMap())
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'Tempo esgotado ao criar sala. Verifique a conexão com o Firebase.');
      });
      await newRoomRef.update({'time': 30.0, 'mapa': 0}).timeout(
          const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'Tempo esgotado ao configurar sala. Verifique a conexão com o Firebase.');
      });

      // Set current room
      currentRoomId = roomId;
      _roomRef = newRoomRef;

      print('[MultiplayerService] Sala criada com sucesso: $roomId');
      return roomId;
    } catch (e) {
      print('[MultiplayerService] Erro ao criar sala: $e');
      rethrow;
    }
  }

  /// Gets a stream of all available rooms
  Stream<List<RoomInfo>> getRoomsList() {
    print('[MultiplayerService] Carregando lista de salas...');
    return _salasRef.onValue.map((event) {
      final List<RoomInfo> rooms = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            rooms.add(RoomInfo.fromMap(key as String, value));
          }
        });
      }
      print('[MultiplayerService] ${rooms.length} salas encontradas.');
      return rooms;
    });
  }

  /// Gets information about a specific room
  Future<RoomInfo?> getRoomInfo(String roomId) async {
    final snapshot = await _salasRef.child(roomId).get();
    if (snapshot.exists) {
      return RoomInfo.fromMap(roomId, snapshot.value as Map<dynamic, dynamic>);
    }
    return null;
  }

  /// Joins a specific room
  Future<void> joinRoom(
    String roomId,
    String idPlayer,
    String nickname,
    Map<String, dynamic> playerData,
  ) async {
    // Set current room reference
    currentRoomId = roomId;
    _roomRef = _salasRef.child(roomId);

    // Add nickname to player data
    playerData['nickname'] = nickname;
    playerData['joinedAt'] = ServerValue.timestamp;

    final playerRef = _roomRef!.child('jogadores/$idPlayer');
    await playerRef.set(playerData).timeout(const Duration(seconds: 10),
        onTimeout: () {
      throw TimeoutException(
          'Tempo esgotado ao entrar na sala. Verifique a conexão com o Firebase.');
    });

    // Auto-remove on disconnect
    await playerRef.onDisconnect().remove();

    // Update player count
    await _updatePlayerCount().timeout(const Duration(seconds: 10),
        onTimeout: () {
      throw TimeoutException(
          'Tempo esgotado ao atualizar contagem de jogadores.');
    });

    // Auto-decrement on disconnect
    _roomRef!.child('jogadores/$idPlayer').onDisconnect().remove().then((_) {
      _updatePlayerCount();
    });

    // Start listening for host election
    _listenForHostElection(idPlayer);
  }

  /// Updates the player count in room info
  Future<void> _updatePlayerCount() async {
    if (_roomRef == null) return;

    final snapshot = await _roomRef!.child('jogadores').get();
    int count = 0;
    if (snapshot.exists) {
      count = snapshot.children.length;
    }

    await _roomRef!.child('info/currentPlayers').set(count);
  }

  /// Leaves the current room
  Future<void> leaveRoom(String idPlayer) async {
    if (_roomRef == null) return;

    try {
      // 1. Verificar quantos jogadores restam ANTES de remover
      final snapshot = await _roomRef!.child('jogadores').get();
      int playerCount = snapshot.exists ? snapshot.children.length : 0;

      // 2. Remover o jogador
      await _roomRef!.child('jogadores/$idPlayer').remove();

      // 3. Se era o último jogador, deletar a sala inteira
      if (playerCount <= 1) {
        print('Último jogador saiu. Deletando sala...');
        await _roomRef!.remove().timeout(const Duration(seconds: 3),
            onTimeout: () {
          print('Timeout ao deletar sala. Prosseguindo...');
          return null;
        }); // Deleta toda a sala do Firebase
      } else {
        // Atualizar contagem de jogadores
        await _updatePlayerCount();
        print('Jogador saiu. $playerCount jogadores restantes.');
      }
    } catch (e) {
      print('Erro ao sair da sala: $e');
    }

    // 4. Cancelar todos os listeners
    _gameStateSub?.cancel();
    _countdownSub?.cancel();

    // 5. Limpar estado local
    _roomRef = null;
    currentRoomId = null;
    amIHost = false;
  }

  /// Updates room status (only host can do this)
  Future<void> updateRoomStatus(String status) async {
    if (!amIHost || _roomRef == null) return;

    await _roomRef!.child('info/status').set(status);
  }

  void _listenForHostElection(String myId) {
    if (_roomRef == null) return;

    _roomRef!.child('jogadores').onValue.listen((event) {
      if (!event.snapshot.exists) return;

      final playersData = event.snapshot.children;
      if (playersData.isEmpty) return;

      // Sort players by joinedAt timestamp
      List<Map<String, dynamic>> sortedPlayers = [];

      for (var child in playersData) {
        final data = Map<String, dynamic>.from(child.value as Map);
        data['key'] = child.key;
        sortedPlayers.add(data);
      }

      sortedPlayers.sort((a, b) {
        final t1 = a['joinedAt'] as int? ?? 0;
        final t2 = b['joinedAt'] as int? ?? 0;
        return t1.compareTo(t2);
      });

      // The first player in the sorted list is the host
      if (sortedPlayers.isNotEmpty) {
        final oldestPlayerId = sortedPlayers.first['key'];
        bool iWasHost = amIHost;
        amIHost = (oldestPlayerId == myId);

        if (amIHost && !iWasHost) {
          print("I am now the HOST!");
          // Take ownership of room state if needed
        }
      }
    });
  }

  /// Subscribes to player changes (added, changed, removed)
  StreamSubscription<DatabaseEvent>? _playersSub;
  StreamSubscription<DatabaseEvent>? _playerRemovedSub;

  void subscribeToPlayerUpdates({
    required String currentPlayerId,
    required Function(String id, Map<String, dynamic> data) onPlayerAdded,
    required Function(String id, Map<String, dynamic> data) onPlayerChanged,
    required Function(String id) onPlayerRemoved,
  }) {
    if (_roomRef == null) return;

    final playersRef = _roomRef!.child('jogadores');

    // Listen for child_added: new players entering the room
    _playersSub = playersRef.onChildAdded.listen((event) {
      if (event.snapshot.key != currentPlayerId &&
          event.snapshot.key != null &&
          event.snapshot.value != null) {
        onPlayerAdded(
          event.snapshot.key!,
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
      }
    });

    // Listen for child_changed: existing players updating state
    playersRef.onChildChanged.listen((event) {
      if (event.snapshot.key != currentPlayerId &&
          event.snapshot.key != null &&
          event.snapshot.value != null) {
        onPlayerChanged(
          event.snapshot.key!,
          Map<String, dynamic>.from(event.snapshot.value as Map),
        );
      }
    });

    // Listen for child_removed: players leaving/disconnecting
    _playerRemovedSub = playersRef.onChildRemoved.listen((event) {
      if (event.snapshot.key != null) {
        onPlayerRemoved(event.snapshot.key!);
      }
    });
  }

  void unsubscribeFromPlayerUpdates() {
    _playersSub?.cancel();
    _playerRemovedSub?.cancel();
  }

  /// Initial load of players existing in the room
  Future<List<Players>> loadExistingPlayers(String currentPlayerId) async {
    List<Players> players = [];
    if (_roomRef == null) return players;

    var counterRef = _roomRef!.child('jogadores');

    try {
      final counterSnapshot = await counterRef.get();

      for (var element in counterSnapshot.children) {
        var data = Map<String, dynamic>.from(element.value as Map);
        if (element.key != currentPlayerId) {
          players.add(Players(
              idPlayer: element.key ?? '',
              position: Vector2(double.parse(data["x"].toString()),
                  double.parse(data["y"].toString()))));
        }
      }
    } catch (err) {
      print('Error loading existing players: $err');
    }
    return players;
  }

  /// Updates the current player's state in the database
  Future<void> updatePlayer(String idPlayer, double x, double y, String state,
      String direction, String character) async {
    if (_roomRef == null) return;

    // Only update specific fields to save bandwidth
    await _roomRef!.child('jogadores/$idPlayer').update({
      "x": x,
      "y": y,
      "state": state,
      'direction': direction,
      'char': character,
    });
  }

  /// Removes player from the room (e.g. on disconnect)
  Future<void> removePlayer(String idPlayer) async {
    if (_roomRef == null) return;

    await _roomRef!.child('jogadores/$idPlayer').remove();
    await _updatePlayerCount();
  }

  // --- GAME STATE SYNC (Timer / Level) ---

  Future<void> updateGameState(double time, int levelIndex) async {
    if (!amIHost || _roomRef == null) return; // Only host updates game state

    await _roomRef!.update({'time': time, 'mapa': levelIndex});
  }

  StreamSubscription<DatabaseEvent>? _gameStateSub;

  void listenToGameState(Function(double time, int level) onUpdate) {
    if (_roomRef == null) return;

    _gameStateSub = _roomRef!.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        double? time = double.tryParse(data['time']?.toString() ?? '');
        int? level = int.tryParse(data['mapa']?.toString() ?? '');

        if (time != null && level != null) {
          onUpdate(time, level);
        }
      }
    });
  }

  // --- COUNTDOWN SYNC ---

  /// Inicia a contagem regressiva (apenas o host pode chamar)
  Future<void> startCountdown() async {
    if (!amIHost || _roomRef == null) return;

    await _roomRef!.update({
      'countdownStarted': true,
      'countdownTimestamp': ServerValue.timestamp,
    });
  }

  StreamSubscription<DatabaseEvent>? _countdownSub;

  /// Escuta o início da contagem regressiva
  void listenToCountdownStart(Function() onCountdownStart) {
    if (_roomRef == null) return;

    _countdownSub = _roomRef!.child('countdownStarted').onValue.listen((event) {
      final started = event.snapshot.value as bool?;
      if (started == true) {
        onCountdownStart();
        // Reset para permitir nova contagem no futuro
        Future.delayed(const Duration(seconds: 5), () {
          if (amIHost && _roomRef != null) {
            _roomRef!.update({'countdownStarted': false});
          }
        });
      }
    });
  }

  // --- CHECKPOINT SYNC ---

  /// Notifica que um checkpoint foi alcançado (qualquer jogador pode chamar)
  Future<void> sendCheckpointReached() async {
    if (_roomRef == null) return;

    // Usamos um timestamp para garantir que o evento seja único e recente
    await _roomRef!.update({
      'checkpointReachedTimestamp': ServerValue.timestamp,
    });
  }

  StreamSubscription<DatabaseEvent>? _checkpointSub;

  /// Escuta se algum checkpoint foi alcançado
  void listenToCheckpointReached(Function() onCheckpointReached) {
    if (_roomRef == null) return;

    _checkpointSub =
        _roomRef!.child('checkpointReachedTimestamp').onValue.listen((event) {
      if (event.snapshot.exists) {
        onCheckpointReached();
      }
    });
  }

  void dispose() {
    _gameStateSub?.cancel();
    _countdownSub?.cancel();
    _checkpointSub?.cancel();
  }

  static void updatePlayerStateFromData(Players jogador, String? state) {
    if (state == null) return;

    switch (state) {
      case "PlayerState.idle":
        jogador.current = PlayerState.idle;
        break;
      case "PlayerState.idle_left":
        jogador.current = PlayerState.idle_left;
        break;
      case "PlayerState.running":
        jogador.current = PlayerState.running;
        break;
      case "PlayerState.running_left":
        jogador.current = PlayerState.running_left;
        break;
      case "PlayerState.jumping":
        jogador.current = PlayerState.jumping;
        break;
      case "PlayerState.jumping_left":
        jogador.current = PlayerState.jumping_left;
        break;
      case "PlayerState.falling":
        jogador.current = PlayerState.falling;
        break;
      case "PlayerState.falling_left":
        jogador.current = PlayerState.falling_left;
        break;
      case "PlayerState.hit":
        jogador.current = PlayerState.hit;
        break;
      case "PlayerState.hit_left":
        jogador.current = PlayerState.hit_left;
        break;
      case "PlayerState.appearing":
        jogador.current = PlayerState.appearing;
        break;
      case "PlayerState.disappearing":
        jogador.current = PlayerState.disappearing;
        break;
    }
  }
}
