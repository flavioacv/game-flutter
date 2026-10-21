import 'package:flutter_test/flutter_test.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final levelName in ['Level-01', 'Level-02', 'Level-03', 'Level-04', 'Level-05', 'Level-06']) {
    test('Test loading $levelName.tmx', () async {
      final tiled = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
      expect(tiled.tileMap.map.width, greaterThan(0));
      expect(tiled.tileMap.map.height, greaterThan(0));
    });
  }
}
