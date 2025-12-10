import 'dart:async';
import 'dart:io';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/checkpoint.dart';
import 'package:pixel_adventure/components/chicken.dart';
import 'package:pixel_adventure/components/fruit.dart';
import 'package:pixel_adventure/components/physics/kina_physics.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/saw.dart';
import 'package:pixel_adventure/components/utils.dart';

class PlayerSpine extends Player {
  PlayerSpine({
    super.position,
    super.character = 'Char 1',
    super.joystick,
    required super.nickName,
    required super.idPlayer,
  });

  @override
  final double stepTime = 0.05;
  @override
  late final SpriteAnimation idleAnimation;
  @override
  late final SpriteAnimation idleLeftAnimation;
  @override
  late final SpriteAnimation runningAnimation;
  @override
  late final SpriteAnimation runningLeftAnimation;
  @override
  late final SpriteAnimation jumpingAnimation;
  @override
  late final SpriteAnimation jumpingLeftAnimation;
  @override
  late final SpriteAnimation fallingAnimation;
  @override
  late final SpriteAnimation fallingLeftAnimation;
  @override
  late final SpriteAnimation hitAnimation;
  @override
  late final SpriteAnimation hitLeftAnimation;
  @override
  late final SpriteAnimation appearingAnimation;
  @override
  late final SpriteAnimation disappearingAnimation;

  @override
  FutureOr<void> onLoad() async {
    // Load PNG sprite animations instead of Spine
    await _loadAllAnimations();

    startingPosition = Vector2(position.x, position.y);

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));

    // Scale to match original 32x32 sprite proportion
    // Original sprites: 32x32, PNG sprites: 633x523
    // Scale = 32 / 633 ≈ 0.0505
    scale = Vector2.all(0.0505);

    // Do NOT call super.onLoad() to avoid loading default character sprites
  }

  Future<void> _loadAllAnimations() async {
    // Load animations from PNG sequences
    idleAnimation = await _spriteAnimationFromFrames('Idle', 20);
    idleLeftAnimation =
        await _spriteAnimationFromFrames('Idle', 20, flipX: true);

    runningAnimation = await _spriteAnimationFromFrames('Run', 30);
    runningLeftAnimation =
        await _spriteAnimationFromFrames('Run', 30, flipX: true);

    jumpingAnimation = await _spriteAnimationFromFrames('Jump', 20);
    jumpingLeftAnimation =
        await _spriteAnimationFromFrames('Jump', 20, flipX: true);

    fallingAnimation = await _spriteAnimationFromFrames('Fall', 10);
    fallingLeftAnimation =
        await _spriteAnimationFromFrames('Fall', 10, flipX: true);

    hitAnimation = await _spriteAnimationFromFrames('Hit', 40, loop: false);
    hitLeftAnimation =
        await _spriteAnimationFromFrames('Hit', 40, flipX: true, loop: false);

    // Use Idle for appearing
    appearingAnimation =
        await _spriteAnimationFromFrames('Idle', 20, loop: false);

    // Use Win for disappearing
    disappearingAnimation =
        await _spriteAnimationFromFrames('Win', 30, loop: false);

    // Set up animations map
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

    // Set initial animation
    current = PlayerState.idle;
  }

  Future<SpriteAnimation> _spriteAnimationFromFrames(
    String animationName,
    int frameCount, {
    bool flipX = false,
    bool loop = true,
  }) async {
    final List<Sprite> sprites = [];

    // Load each frame from the PNG sequence
    for (int i = 0; i < frameCount; i++) {
      final frameName =
          'Character-${animationName}_${i.toString().padLeft(2, '0')}.png';
      final path =
          'New Characters/$character/Png/Character Sprite/$animationName/$frameName';

      try {
        final image = await game.images.load(path);
        sprites.add(Sprite(image));
      } catch (e) {
        print('Error loading frame $path: $e');
        // If frame loading fails, break and use what we have
        break;
      }
    }

    if (sprites.isEmpty) {
      throw Exception('No sprites loaded for animation: $animationName');
    }

    return SpriteAnimation.spriteList(
      sprites,
      stepTime: stepTime,
      loop: loop,
    );
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    KinaPhysics.updateTime(dt);

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

    if (Platform.isAndroid || Platform.isIOS) {
      updateJoystick();
    }

    if (bag) {
      _gravity = 10.8;
    } else {
      _gravity = 8.8;
    }

    // Call super to update sprite animations
    super.update(dt);
  }

  // Override these private methods from Player since they're not accessible
  double _gravity = 8.8;
  final double _jumpForce = 180;
  final double _terminalVelocity = 300;

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (direction == "left") {
      playerState = PlayerState.idle_left;
    } else {
      playerState = PlayerState.idle;
    }

    if (velocity.x > 0 || velocity.x < 0) {
      if (direction == "right") {
        playerState = PlayerState.running;
      } else {
        playerState = PlayerState.running_left;
      }
    }

    if (velocity.y > 0 && !isSliding) {
      if (direction == "right") {
        playerState = PlayerState.falling;
      } else {
        playerState = PlayerState.falling_left;
      }
    }

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

            final kinaResult = KinaPhysics.checkKinaCollision(
              playerPosition: position,
              playerVelocity: velocity,
              playerHitbox: hitbox,
              playerDirection: direction,
              playerState: current,
              block: block,
            );

            if (kinaResult.triggered) {
              velocity.x += kinaResult.boostX;
              velocity.y -= kinaResult.boostY;
              moveSpeed = 130;
              isSliding = true;

              if (direction == 'right') {
                current = PlayerState.running;
              } else {
                current = PlayerState.running_left;
              }

              if (kinaResult.isSuperKina) {
                kinaFeedback =
                    '🚀 SUPER KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
              } else {
                kinaFeedback =
                    '⚡ KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
              }
              kinaFeedbackTimer = 1.5;
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

            final kinaResult = KinaPhysics.checkKinaCollision(
              playerPosition: position,
              playerVelocity: velocity,
              playerHitbox: hitbox,
              playerDirection: direction,
              playerState: current,
              block: block,
            );

            if (kinaResult.triggered) {
              velocity.x += kinaResult.boostX;
              velocity.y -= kinaResult.boostY;
              moveSpeed = 130;
              isSliding = true;

              if (direction == 'right') {
                current = PlayerState.running;
              } else {
                current = PlayerState.running_left;
              }

              if (kinaResult.isSuperKina) {
                kinaFeedback =
                    '🚀 SUPER KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
              } else {
                kinaFeedback =
                    '⚡ KINA! +${kinaResult.boostX.abs().toStringAsFixed(0)}';
              }
              kinaFeedbackTimer = 1.5;
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
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    if (direction == "right") {
      current = PlayerState.hit;
    } else {
      current = PlayerState.hit_left;
    }

    scale.x = 1;
    position = startingPosition - Vector2.all(32);
    current = PlayerState.appearing;

    await Future.delayed(const Duration(seconds: 1));

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMoveDuration, () => gotHit = false);
  }

  void _reachedCheckpoint() async {
    bag = false;
    reachedCheckpoint = true;
    current = PlayerState.disappearing;
    await Future.delayed(const Duration(seconds: 1));
    game.onPlayerReachedCheckpoint();
    reachedCheckpoint = false;
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
        _reachedCheckpoint();
      }
    }
    // Call super to respect @mustCallSuper annotation
    super.onCollisionStart(intersectionPoints, other);
  }
}
