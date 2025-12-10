import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  final bool isPlatform;
  final String type;

  CollisionBlock({
    required Vector2 position,
    required Vector2 size,
    this.isPlatform = false,
    this.type = '',
  }) {
    this.position = position;
    this.size = size;
  }
}
