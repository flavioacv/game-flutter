import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/custom_hitbox.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Players extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String _character;

  set character(String name) {
    if (_character != name) {
      _character = name;
      _loadAllAnimations();
    }
  }

  String get character => _character;

  Players({
    position,
    String character = 'Ninja Frog',
    required this.idPlayer,
    this.nickName = '',
  })  : _character = character,
        super(position: position);

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

  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;
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
    //_updatePlayerState();
    // accumulatedTime += dt;

    // while (accumulatedTime >= fixedDeltaTime) {
    //   if (!gotHit && !reachedCheckpoint) {
    //     //_updatePlayerState();
    //   }

    //   accumulatedTime -= fixedDeltaTime;
    // }
    // FirebaseDatabase.instance.ref('sala/jogador1').remove();

    // FirebaseFirestore.instance.collection('room').add({
    //   "x": x,
    //   "y": y,
    // });
    super.update(dt);
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
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(96),
        loop: false,
      ),
    );
  }

  void updatePlayerState() {
    //flipHorizontallyAroundCenter();
  }
}
