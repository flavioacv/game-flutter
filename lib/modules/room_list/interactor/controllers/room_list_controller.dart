import 'dart:async';

import 'package:pixel_adventure/core/constants/key_local_storage/key_local_storage.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/core/services/multiplayer/multiplayer_service.dart';
import 'package:pixel_adventure/modules/room_list/interactor/exceptions/room_list_exception.dart';
import 'package:pixel_adventure/modules/room_list/interactor/models/room_model.dart';
import 'package:pixel_adventure/modules/room_list/interactor/state/room_list_state.dart';

class RoomListController {
  final MultiplayerService _multiplayerService;
  final LocalStorageService _localStorageService;

  RoomListController(this._multiplayerService, this._localStorageService);

  final StreamController<RoomListState> _stateController =
      StreamController<RoomListState>.broadcast();

  Stream<RoomListState> get state => _stateController.stream;

  StreamSubscription? _roomsSubscription;

  void _emit(RoomListState newState) {
    _stateController.add(newState);
  }

  /// Load rooms from Firebase
  void loadRooms() {
    _emit(RoomListLoadingState());

    _roomsSubscription?.cancel();
    _roomsSubscription = _multiplayerService.getRoomsList().listen(
      (rooms) {
        // Convert RoomInfo to RoomModel
        final roomModels = rooms.map((roomInfo) {
          return RoomModel(
            id: roomInfo.id,
            name: roomInfo.name,
            hostId: roomInfo.hostId,
            maxPlayers: roomInfo.maxPlayers,
            currentPlayers: roomInfo.currentPlayers,
            createdAt: roomInfo.createdAt,
            status: _parseStatus(roomInfo.status),
          );
        }).toList();

        _emit(RoomListLoadedState(roomModels));
      },
      onError: (error) {
        _emit(RoomListErrorState('Erro ao carregar salas: $error'));
      },
    );
  }

  RoomStatus _parseStatus(String status) {
    switch (status) {
      case 'waiting':
        return RoomStatus.waiting;
      case 'playing':
        return RoomStatus.playing;
      case 'finished':
        return RoomStatus.finished;
      default:
        return RoomStatus.waiting;
    }
  }

  /// Create a new room
  Future<void> createRoom(String roomName, int maxPlayers) async {
    try {
      _emit(RoomListCreatingState());

      // Get user info
      final userId =
          await _localStorageService.getString(KeyLocalStorage.KEY_ID_USER);
      final nickname =
          await _localStorageService.getString(KeyLocalStorage.KEY_NICK_USER);

      if (userId == null || userId.isEmpty) {
        throw RoomListException('Usuário não autenticado');
      }

      if (roomName.trim().isEmpty) {
        throw RoomListException('Nome da sala não pode ser vazio');
      }

      if (roomName.length > 20) {
        throw RoomListException(
            'Nome da sala muito longo (máx. 20 caracteres)');
      }

      // Create room
      final roomId = await _multiplayerService.createRoom(
        roomName.trim(),
        userId,
        nickname ?? 'Jogador',
        maxPlayers,
      );

      _emit(RoomListCreatedState(roomId));
    } catch (e) {
      if (e is RoomListException) {
        _emit(RoomListErrorState(e.message));
      } else {
        _emit(RoomListErrorState('Erro ao criar sala: $e'));
      }
    }
  }

  /// Join an existing room
  Future<void> joinRoom(String roomId, String characterSelected) async {
    try {
      _emit(RoomListJoiningState(roomId));

      // Get room info to validate
      final roomInfo = await _multiplayerService.getRoomInfo(roomId);

      if (roomInfo == null) {
        throw RoomListException('Sala não encontrada');
      }

      if (roomInfo.currentPlayers >= roomInfo.maxPlayers) {
        throw RoomListException('Sala cheia');
      }

      if (roomInfo.status != 'waiting') {
        throw RoomListException('Sala já iniciada');
      }

      // Get user info
      final userId =
          await _localStorageService.getString(KeyLocalStorage.KEY_ID_USER);
      final nickname =
          await _localStorageService.getString(KeyLocalStorage.KEY_NICK_USER);

      if (userId == null || userId.isEmpty) {
        throw RoomListException('Usuário não autenticado');
      }

      // Join room
      await _multiplayerService.joinRoom(
        roomId,
        userId,
        nickname ?? 'Jogador',
        {
          'char': characterSelected,
          'x': 0,
          'y': 0,
          'direction': 'right',
          'state': 'PlayerState.idle',
        },
      );

      _emit(RoomListJoinedState(roomId));
    } catch (e) {
      if (e is RoomListException) {
        _emit(RoomListErrorState(e.message));
      } else {
        _emit(RoomListErrorState('Erro ao entrar na sala: $e'));
      }
    }
  }

  void dispose() {
    _roomsSubscription?.cancel();
    _stateController.close();
  }
}
