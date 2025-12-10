import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class RightButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  RightButton();

  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/RightButton.png'));
    position = Vector2(
      margin.toDouble() + buttonSize,
      game.size.y - margin - buttonSize,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.horizontalMovement = 1;

    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.horizontalMovement = 0;
    game.player.oldPosition = x;
    super.onTapUp(event);
  }
}
