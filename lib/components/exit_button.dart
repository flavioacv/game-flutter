import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

/// Botão de sair no canto superior esquerdo durante o jogo
class ExitButton extends PositionComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  ExitButton();

  final margin = 10;
  final buttonSize = 40.0;

  @override
  FutureOr<void> onLoad() async {
    size = Vector2.all(buttonSize);
    position = Vector2(
      margin.toDouble(),
      margin.toDouble(),
    );
    priority = 100; // Alto para ficar acima de tudo

    // Criar círculo vermelho de fundo
    final background = CircleComponent(
      radius: buttonSize / 2,
      paint: Paint()..color = Colors.red.withOpacity(0.8),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(background);

    // Criar X branco
    final xLine1 = RectangleComponent(
      size: Vector2(buttonSize * 0.6, 3),
      paint: BasicPalette.white.paint(),
      anchor: Anchor.center,
      position: size / 2,
      angle: 0.785398, // 45 graus em radianos
    );
    add(xLine1);

    final xLine2 = RectangleComponent(
      size: Vector2(buttonSize * 0.6, 3),
      paint: BasicPalette.white.paint(),
      anchor: Anchor.center,
      position: size / 2,
      angle: -0.785398, // -45 graus em radianos
    );
    add(xLine2);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Pausar o jogo
    game.pauseEngine();

    // Mostrar confirmação via overlay
    game.overlays.add('ExitConfirmation');

    super.onTapDown(event);
  }
}
