import 'dart:async';
import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/components/countdown_component.dart';
import 'package:pixel_adventure/components/exit_button.dart';
import 'package:pixel_adventure/components/jump_button.dart';
import 'package:pixel_adventure/components/kina_feedback.dart';
import 'package:pixel_adventure/components/level.dart';
import 'package:pixel_adventure/components/physics/kina_physics.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/players.dart';
import 'package:pixel_adventure/core/constants/key_local_storage/key_local_storage.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/core/services/multiplayer/multiplayer_service.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure(
      {required this.widthScreen,
      required this.heightScreen,
      required this.localStorageService,
      required this.roomId,
      this.characterSelected = 'Ninja Frog'});

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  final LocalStorageService localStorageService;
  final MultiplayerService multiplayerService = MultiplayerService();
  final String characterSelected;
  final String roomId;
  final double widthScreen;
  final double heightScreen;
  late CameraComponent cam;
  late Player
      player; // Changed from Player to PositionComponent to support Spine
  late JoystickComponent? joystick;
  late KinaFeedback kinaFeedbackComponent;
  bool showControls = false;
  bool playSounds = true;
  double soundVolume = 1.0;
  List<String> levelNames = [
    // 'Level-01',
    // 'Level-02',
    // 'Level-03',
    'Level-04',
    'Level-05',
  ];
  int currentLevelIndex = 0;
  late String? idUser;
  late TextComponent timerText;
  double countdownTime = 30.0; // 2 minutos (120 segundos)
  bool timerActive = false; // Inicia pausado até a contagem terminar
  bool gameStarted = false; // Controla se o jogo já iniciou
  bool countdownActive = false; // Controla se a contagem está ativa

  @override
  FutureOr<void> onLoad() async {
    // Load all images into cache
    idUser = await localStorageService.getString(KeyLocalStorage.KEY_ID_USER);
    String? nickName =
        await localStorageService.getString(KeyLocalStorage.KEY_NICK_USER);

    if (idUser != null) {
      await multiplayerService.joinRoom(
        roomId,
        idUser!,
        nickName ?? 'Jogador',
        {
          'char': characterSelected,
          'x': 0, // Initial position, will update later
          'y': 0,
          'direction': 'right',
          'state': 'PlayerState.idle'
        },
      );

      multiplayerService.listenToGameState((time, level) {
        if (!multiplayerService.amIHost) {
          countdownTime = time;
          // Only activate timer if we are NOT in a countdown (Get Ready phase)
          if (countdownTime > 0 && !countdownActive) {
            timerActive =
                true; // Reativa o timer se receber tempo positivo do host
          }
          if (currentLevelIndex != level) {
            currentLevelIndex = level;
            isFinalizing = false; // Reseta flag ao mudar de nível
            _loadLevel();
          }
        }
      });

      // Escutar início da contagem regressiva
      multiplayerService.listenToCountdownStart(() {
        print("LISTENER: Countdown start received from server");
        if (!countdownActive) {
          startCountdown();
        }
      });

      // Escutar se alguém chegou no checkpoint
      multiplayerService.listenToCheckpointReached(() {
        _onCheckpointReached();
      });
    }

    await images.loadAllImages();
    if (Platform.isAndroid || Platform.isIOS) {
      final sprite = await loadSprite('HUD/Joystick.png');
      joystick = JoystickComponent(
        priority: 10,
        // knob: CircleComponent(
        //   radius: 20,
        //   paint: BasicPalette.gray.withAlpha(159).paint(),
        // ),
        knob: SpriteComponent(
          sprite: sprite,
          size: Vector2.all(40),
        ),
        background: CircleComponent(
          radius: 50,
          paint: BasicPalette.lightBlue.withAlpha(20).paint(),
        ),
        margin: const EdgeInsets.only(left: 70, bottom: 30),
      );
    } else {
      joystick = null;
    }
    timerText = TextComponent(
      text: _formatTime(countdownTime), // Formata o tempo inicial
      textRenderer: TextPaint(
        style: GoogleFonts.lilitaOne(
          fontSize: 16.0,
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(widthScreen / 2 - 15, 5), // Centralizado no topo
      priority: 100, // Para ficar acima da cena
    );

    // Initial Camera Setup
    cam = CameraComponent.withFixedResolution(
      hudComponents: [
        timerText,
        if (joystick != null) joystick!,
        JumpButton(),
        ExitButton(), // Botão de sair no canto superior esquerdo
      ],
      width: widthScreen,
      height: heightScreen,
    );
    // Note: we don't set 'world' here yet, or we set a placeholder.
    // In Flame, CameraComponent is added to the game, and the World is added to the game.
    // But we need a World instance to init the camera or we set it later.

    // We will initialize a first level.
    // _loadLevel will take care of creating the level and setting it to the camera.
    // But we need to add 'cam' to the game first.
    add(cam);

    _loadLevel();
    // Criar o timer na tela

    return super.onLoad();
  }

  bool isFinalizing =
      false; // Flag para indicar se está no tempo de finalização

  @override
  void update(double dt) {
    super.update(dt);
    if (timerActive && countdownTime > 0) {
      countdownTime -= dt; // Diminui o tempo
      timerText.text = _formatTime(countdownTime); // Atualiza o texto

      // Update Server if Host
      if (multiplayerService.amIHost) {
        multiplayerService.updateGameState(countdownTime, currentLevelIndex);
      }

      if (countdownTime <= 0) {
        // Lógica controlada pelo HOST (ou offline)
        if (multiplayerService.amIHost || idUser == null) {
          if (!isFinalizing) {
            // Entra na fase de finalização (15 segundos)
            isFinalizing = true;
            countdownTime = 15.0;
            // Opcional: Adicionar lógica visual ou sonora aqui para indicar a transição
          } else {
            // Fim da fase de finalização
            timerActive = false; // Para o timer ao chegar em 0
            timerText.text = "00:00"; // Garante que fique em 00:00
            isFinalizing = false; // Reseta a flag
            loadNextLevel();
          }
        } else {
          // CLIENT: Apenas para e aguarda sincronização do Host
          timerActive = false;
          timerText.text = "00:00";
        }
      }
    }

    // SEND PLAYER UPDATES
    if (idUser != null && gameStarted) {
      multiplayerService.updatePlayer(
        idUser!,
        player.x,
        player.y,
        player.current.toString(),
        player.direction,
        player.character,
      );
    }
  }

  String _formatTime(double time) {
    int minutes = (time ~/ 60); // Pega os minutos
    int seconds = (time % 60).toInt(); // Pega os segundos restantes
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> loadNextLevel() async {
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
    } else {
      // no more levels
      currentLevelIndex = 0;
    }

    // Reset timer for the new level
    countdownTime = 30.0;
    timerText.text = _formatTime(countdownTime); // UPDATE UI IMMEDIATELY

    // FORCE UPDATE to Server so clients know level changed
    if (multiplayerService.amIHost) {
      multiplayerService.updateGameState(countdownTime, currentLevelIndex);
    }

    _loadLevel();
  }

  Level? currentLevelComponent; // Keep track of current level

  void _loadLevel() async {
    // Safety check for level index
    if (currentLevelIndex >= levelNames.length || currentLevelIndex < 0) {
      print(
          "Warning: Level index $currentLevelIndex out of bounds. Resetting to 0.");
      currentLevelIndex = 0;
    }

    String? nickName;
    nickName =
        await localStorageService.getString(KeyLocalStorage.KEY_NICK_USER);

    // Create new player instance
    player = Player(
        idPlayer: idUser ?? '',
        nickName: nickName ?? '',
        character: characterSelected,
        joystick: Platform.isAndroid || Platform.isIOS
            ? joystick
            : null); // null joystick on desktop
    Future.delayed(const Duration(milliseconds: 100), () {
      // Remove old level/world if exists
      if (cam.world != null) {
        // Flame 1.21: World is a component in the game.
        // We must remove the OLD world from the game to stop it updating.
        remove(cam.world!);
      }

      // Unsubscribe from old listener
      multiplayerService.unsubscribeFromPlayerUpdates();

      Level newWorld = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      currentLevelComponent = newWorld; // Store reference

      // Add the new world to the game
      add(newWorld);

      // Tell camera to watch the new world
      cam.world = newWorld;

      // Camera follows the new player
      cam.follow(player);

      // SUBSCRIBE TO REMOTE PLAYERS
      if (idUser != null) {
        multiplayerService.subscribeToPlayerUpdates(
            currentPlayerId: idUser!,
            onPlayerAdded: (id, data) {
              print("Remote Player Added: $id");
              final newPlayer = Players(
                idPlayer: id,
                nickName: data['nickname'] ?? '',
                character: data['char'] ?? 'Ninja Frog',
              );

              if (data.containsKey('x') && data.containsKey('y')) {
                newPlayer.position = Vector2(
                  double.parse(data['x'].toString()),
                  double.parse(data['y'].toString()),
                );
              }

              newPlayer.direction = data['direction'] ?? 'right';
              MultiplayerService.updatePlayerStateFromData(
                  newPlayer, data['state']);

              currentLevelComponent?.add(newPlayer);
              currentLevelComponent?.listPlayers.add(newPlayer);
            },
            onPlayerChanged: (id, data) {
              final existingPlayer = currentLevelComponent?.listPlayers
                  .firstWhere((p) => p.idPlayer == id,
                      orElse: () => Players(idPlayer: 'dummy'));

              if (existingPlayer != null &&
                  existingPlayer.idPlayer != 'dummy') {
                if (data.containsKey('x') && data.containsKey('y')) {
                  existingPlayer.position = Vector2(
                    double.parse(data['x'].toString()),
                    double.parse(data['y'].toString()),
                  );
                }
                if (data.containsKey('direction')) {
                  existingPlayer.direction = data['direction'];
                }
                if (data.containsKey('char')) {
                  // We check if char changed to reload if necessary
                  if (existingPlayer.character != data['char']) {
                    existingPlayer.character = data['char'];
                    // Trigger reload of animations
                    existingPlayer
                        .updatePlayerState(); // Using this as a trigger if implemented
                  }
                }
                if (data.containsKey('state')) {
                  MultiplayerService.updatePlayerStateFromData(
                      existingPlayer, data['state']);
                }
              }
            },
            onPlayerRemoved: (id) {
              print("Remote Player Removed: $id");
              final existingPlayer = currentLevelComponent?.listPlayers
                  .firstWhere((p) => p.idPlayer == id,
                      orElse: () => Players(idPlayer: 'dummy'));

              if (existingPlayer != null &&
                  existingPlayer.idPlayer != 'dummy') {
                existingPlayer.removeFromParent();
                currentLevelComponent?.listPlayers.remove(existingPlayer);
              }
            });
      }

      // Configurar sistema Kina - MODO TESTE (zona maior para facilitar)
      KinaPhysics.config = const KinaConfig(
        debugMode: false, // Logs no código do player agora
        edgeZoneNormal: 8.0, // Zona maior (8px) para facilitar testes
        edgeZoneSuper: 3.0, // Super kina em 3px
        baseBoostXNormal: 50.0,
        baseBoostYNormal: 30.0,
        baseBoostXSuper: 120.0,
        baseBoostYSuper: 60.0,
      );
      KinaPhysics.resetTime();

      // Criar e adicionar feedback visual do Kina
      // KinaFeedback expects Player. If we have PlayerSpine, we might need adjustments.
      kinaFeedbackComponent = KinaFeedback(player: player);
      cam.viewport.add(kinaFeedbackComponent);

      startCountdown();
    });
  }

  /// Inicia a contagem regressiva de 3 segundos
  void startCountdown() {
    print("START COUNTDOWN CALLED. Active: $countdownActive");
    if (countdownActive) return; // Evita múltiplas contagens

    // Verificar se a câmera já foi inicializada
    try {
      // Tenta acessar cam para verificar se foi inicializado
      final _ = cam.viewport;
    } catch (e) {
      print("Camera not initialized yet, deferring countdown");
      Future.delayed(const Duration(milliseconds: 100), () => startCountdown());
      return;
    }

    countdownActive = true;
    gameStarted = false;
    timerActive = false;

    print("ADDING COUNTDOWN COMPONENT");
    // Criar componente de contagem no centro da tela
    final countdown = CountdownComponent(
      position: Vector2(widthScreen / 2, heightScreen / 2),
      onComplete: () {
        print("COUNTDOWN COMPLETE");
        // Quando a contagem terminar
        gameStarted = true;
        countdownActive = false;
        timerActive = true;

        // Resetar o timer se for o host
        if (multiplayerService.amIHost) {
          countdownTime = 30.0;
          multiplayerService.updateGameState(countdownTime, currentLevelIndex);
        }
      },
    );

    // Adicionar ao viewport da câmera para ficar fixo na tela
    cam.viewport.add(countdown);

    // Se for o host, notificar outros jogadores
    if (multiplayerService.amIHost) {
      print("I AM HOST, SENDING START COUNTDOWN");
      multiplayerService.startCountdown();
    }
  }

  /// Chamado quando ALGUM jogador (local ou remoto) toca no checkpoint
  void _onCheckpointReached() {
    // Só alteramos o estado se ainda não estivermos na fase de finalização
    if (!isFinalizing) {
      print("Checkpoint reached! Setting timer to 15s.");
      isFinalizing = true;
      countdownTime = 15.0; // Reseta para 15 segundos

      // Se eu sou o host, preciso propagar esse novo tempo para todos
      if (multiplayerService.amIHost) {
        multiplayerService.updateGameState(countdownTime, currentLevelIndex);
      }
    } else {
      print("Checkpoint reached but already finalizing. Ignoring.");
    }
  }

  /// Chamado pelo componente Checkpoint quando o player local o toca
  void onPlayerReachedCheckpoint() {
    // Apenas notificamos o serviço. O serviço vai disparar o evento que chamará _onCheckpointReached
    // tanto para nós quanto para os outros.
    multiplayerService.sendCheckpointReached();
  }

  /// Sai da sala atual e volta para a lista de salas
  Future<void> leaveRoom() async {
    if (idUser != null) {
      await multiplayerService.leaveRoom(idUser!);
    }

    // Remover overlay se estiver ativo
    overlays.remove('MainMenu');

    // Pausar o jogo
    paused = true;
  }
}
