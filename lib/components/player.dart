import 'dart:async';
import 'dart:io';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/physics/kina_physics.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  idle_left,
  running,
  running_left,
  jumping,
  jumping_left,
  falling,
  falling_left,
  hit,
  hit_left,
  appearing,
  disappearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  bool isSliding = false;
  Player({
    position,
    this.character = 'Ninja Frog',
    this.joystick,
    required this.nickName,
    required this.idPlayer,
  }) : super(position: position);
  final String nickName;
  final String idPlayer;

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation idleLeftAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation runningLeftAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation jumpingLeftAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation fallingLeftAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation hitLeftAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  double _gravity = 8.8;
  final double _jumpForce = 180;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
  double oldPosition = 0;
  double oldHorizontalMovement = 0;
  String direction = "right";
  List<CollisionBlock> collisionBlocks = [];
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  );
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  final JoystickComponent? joystick;
  bool bag = false;

  // Feedback visual do Kina
  String kinaFeedback = '';
  double kinaFeedbackTimer = 0.0;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    // Atualizar tempo do sistema Kina
    KinaPhysics.updateTime(dt);

    // Atualizar timer do feedback visual
    if (kinaFeedbackTimer > 0) {
      kinaFeedbackTimer -= dt;
      if (kinaFeedbackTimer <= 0) {
        kinaFeedback = '';
      }
    }

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint && game.gameStarted) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
      }

      accumulatedTime -= fixedDeltaTime;
    }
    death();
    if (Platform.isAndroid) {
      updateJoystick();
    }
    // FirebaseDatabase.instance.ref('sala/jogador1').remove();
    // FirebaseDatabase.instance.ref('sala/0/jogadores/$idPlayer').set({
    //   "x": x,
    //   "y": y,
    //   "state": current.toString(),
    //   'direction': direction,
    //   'char': character,
    // });

    // FirebaseFirestore.instance.collection('room').add({
    //   "x": x,
    //   "y": y,
    // });
    if (bag) {
      _gravity = 10.8;
    } else {
      _gravity = 8.8;
    }
    super.update(dt);
  }

  void updateJoystick() {
    switch (joystick?.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        horizontalMovement = -1;
        direction = "left";
        if (horizontalMovement != oldHorizontalMovement) {
          oldHorizontalMovement = horizontalMovement;
          oldPosition = x;
        }
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        horizontalMovement = 1;
        direction = "right";
        if (horizontalMovement != oldHorizontalMovement) {
          oldHorizontalMovement = horizontalMovement;
          oldPosition = x;
        }
        break;
      default:
        horizontalMovement = 0;
        break;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (isRightKeyPressed) {
      oldPosition = x;
      direction = "right";
    }
    if (isLeftKeyPressed) {
      direction = "left";
      oldPosition = x;
    }

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    // oldPosition = x;
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        bag = true;
        other.collidedWithPlayer();
      }
      if (other is Saw) _respawn();
      if (other is Chicken) other.collidedWithPlayer();
      if (other is Checkpoint) {
        // if (bag) {
        _reachedCheckpoint();
        // }
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);
    idleLeftAnimation = _spriteAnimation('Idle-left', 11);
    runningAnimation = _spriteAnimation('Run', 12);
    runningLeftAnimation = _spriteAnimation('Run-left', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    jumpingLeftAnimation = _spriteAnimation('Jump-left', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    fallingLeftAnimation = _spriteAnimation('Fall-left', 1);
    hitAnimation = _spriteAnimation('Hit', 7)..loop = false;
    hitLeftAnimation = _spriteAnimation('Hit-left', 7)..loop = false;
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);

    // List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.idle_left: idleLeftAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.running_left: runningLeftAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.jumping_left: jumpingLeftAnimation,
      PlayerState.falling: fallingAnimation,
      PlayerState.falling_left: fallingLeftAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.hit_left: hitLeftAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    // Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (direction == "left") {
      playerState = PlayerState.idle_left;
    } else {
      playerState = PlayerState.idle;
    }

    if (velocity.x < 0 && scale.x > 0) {
      //flipHorizontallyAroundCenter();

      //direction = "left";
    } else if (velocity.x > 0 && scale.x < 0) {
      //flipHorizontallyAroundCenter();

      // direction = "right";
    }

    // Check if moving, set running
    if (velocity.x > 0 || velocity.x < 0) {
      if (direction == "right") {
        playerState = PlayerState.running;
      } else {
        playerState = PlayerState.running_left;
      }
    }

    // check if Falling set to falling
    if (velocity.y > 0 && !isSliding) {
      if (direction == "right") {
        playerState = PlayerState.falling;
      } else {
        playerState = PlayerState.falling_left;
      }
    }

    // Checks if jumping, set to jumping
    if (velocity.y < 0) {
      if (direction == "right") {
        playerState = PlayerState.jumping;
      } else {
        playerState = PlayerState.jumping_left;
      }
    }

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);

    // if (velocity.y > _gravity) isOnGround = false; // optional

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
    if (isSliding) {
      velocity.x *= 0.5;
      if (velocity.x.abs() < 10) {
        velocity.x = 0;
        isSliding = false;
        moveSpeed = 100;
      }
    }
  }

  void _playerJump(double dt) {
    //if (game.playSounds) FlameAudio.play('jump.wav', volume: game.soundVolume);

    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
    if (Platform.isAndroid) {
      oldPosition = x;
    }
  }

  void _checkHorizontalCollisions() async {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            isSliding = false;
            moveSpeed = 100;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            if (oldPosition != x) {
              isOnGround = true;
            }
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            isSliding = false;
            moveSpeed = 100;
            //position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            position.x =
                block.x + block.width - hitbox.width + hitbox.offsetX - 5;
            if (oldPosition != x) {
              isOnGround = true;
            }
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;

            // DEBUG: Verificar se está tentando kina
            print(
                '🔍 Verificando kina - Estado: $current, Direção: $direction');

            // Verificar kina usando o novo sistema
            final kinaResult = KinaPhysics.checkKinaCollision(
              playerPosition: position,
              playerVelocity: velocity,
              playerHitbox: hitbox,
              playerDirection: direction,
              playerState: current,
              block: block,
            );

            if (kinaResult.triggered) {
              // Aplicar impulso kina
              velocity.x += kinaResult.boostX;
              velocity.y -= kinaResult.boostY;

              // Efeito de deslize
              moveSpeed = 130;
              isSliding = true;

              // Atualizar animação
              if (direction == 'right') {
                current = PlayerState.running;
              } else {
                current = PlayerState.running_left;
              }

              // FEEDBACK VISUAL E LOGS
              if (kinaResult.isSuperKina) {
                kinaFeedback =
                    '🚀 SUPER KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
                print('═══════════════════════════════════');
                print('🚀 SUPER KINA ATIVADO!');
                print('   Borda: ${kinaResult.edgeType}');
                print(
                    '   Precisão: ${(kinaResult.precisionFactor * 100).toStringAsFixed(1)}%');
                print('   Boost X: ${kinaResult.boostX.toStringAsFixed(1)}');
                print('   Boost Y: ${kinaResult.boostY.toStringAsFixed(1)}');
                print('═══════════════════════════════════');
              } else {
                kinaFeedback =
                    '⚡ KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
                print(
                    '⚡ KINA NORMAL - Boost: ${kinaResult.boostX.toStringAsFixed(1)}');
              }
              kinaFeedbackTimer = 1.5; // Mostra por 1.5 segundos
            }

            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;

            // Verificar kina usando o novo sistema
            final kinaResult = KinaPhysics.checkKinaCollision(
              playerPosition: position,
              playerVelocity: velocity,
              playerHitbox: hitbox,
              playerDirection: direction,
              playerState: current,
              block: block,
            );

            if (kinaResult.triggered) {
              // Aplicar impulso kina
              velocity.x += kinaResult.boostX;
              velocity.y -= kinaResult.boostY;

              // Efeito de deslize
              moveSpeed = 130;
              isSliding = true;

              // Atualizar animação
              if (direction == 'right') {
                current = PlayerState.running;
              } else {
                current = PlayerState.running_left;
              }

              // FEEDBACK VISUAL E LOGS
              if (kinaResult.isSuperKina) {
                kinaFeedback =
                    '🚀 SUPER KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
                print('═══════════════════════════════════');
                print('🚀 SUPER KINA ATIVADO!');
                print('   Borda: ${kinaResult.edgeType}');
                print(
                    '   Precisão: ${(kinaResult.precisionFactor * 100).toStringAsFixed(1)}%');
                print('   Boost X: ${kinaResult.boostX.toStringAsFixed(1)}');
                print('   Boost Y: ${kinaResult.boostY.toStringAsFixed(1)}');
                print('═══════════════════════════════════');
              } else {
                kinaFeedback =
                    '⚡ KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
                print(
                    '⚡ KINA NORMAL - Boost: ${kinaResult.boostX.toStringAsFixed(1)}');
              }
              kinaFeedbackTimer = 1.5; // Mostra por 1.5 segundos
            }

            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void _respawn() async {
    bag = false;
    // if (game.playSounds) FlameAudio.play('hit.wav', volume: game.soundVolume);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    if (direction == "right") {
      current = PlayerState.hit;
    } else {
      current = PlayerState.hit_left;
    }

    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  void _reachedCheckpoint() async {
    bag = false;
    reachedCheckpoint = true;
    // if (game.playSounds) {
    //   FlameAudio.play('disappear.wav', volume: game.soundVolume);
    // }
    // if (scale.x > 0) {
    //   position = position - Vector2.all(32);
    // } else if (scale.x < 0) {
    //   position = position + Vector2(32, -32);
    // }

    current = PlayerState.disappearing;

    await animationTicker?.completed;
    animationTicker?.reset();

    reachedCheckpoint = false;
    // position = Vector2.all(-640);

    // const waitToChangeDuration = Duration(seconds: 2);
    // Future.delayed(waitToChangeDuration, () => game.loadNextLevel());
  }

  void death() {
    if (y >= 1000) {
      _respawn();
    }
  }

  void collidedwithEnemy() {
    _respawn();
  }
}
