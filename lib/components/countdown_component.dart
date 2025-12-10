import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

/// Componente de contagem regressiva que exibe 3, 2, 1, GO!
/// antes do início da partida
class CountdownComponent extends TextComponent with HasGameRef<PixelAdventure> {
  CountdownComponent({
    required this.onComplete,
    super.position,
  });

  final VoidCallback onComplete;

  int currentCount = 3;
  double elapsedTime = 0;
  bool isComplete = false;

  // Duração de cada número (em segundos)
  static const double countDuration = 1.0;

  @override
  FutureOr<void> onLoad() {
    // Configuração inicial do texto
    text = currentCount.toString();
    textRenderer = TextPaint(
      style: GoogleFonts.lilitaOne(
        fontSize: 120.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          const Shadow(
            blurRadius: 20.0,
            color: Colors.black,
            offset: Offset(5.0, 5.0),
          ),
          const Shadow(
            blurRadius: 10.0,
            color: Color(0xFF11AC00),
            offset: Offset(0, 0),
          ),
        ],
      ),
    );

    // Centralizar o texto
    anchor = Anchor.center;

    // Prioridade alta para aparecer sobre tudo
    priority = 1000;

    // Escala inicial para animação
    scale = Vector2.all(0.5);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isComplete) return;

    elapsedTime += dt;

    // Animação de escala (cresce e diminui)
    double progress = (elapsedTime % countDuration) / countDuration;

    if (progress < 0.3) {
      // Cresce rapidamente
      scale = Vector2.all(0.5 + (progress / 0.3) * 0.7); // 0.5 -> 1.2
    } else if (progress < 0.6) {
      // Volta ao tamanho normal
      double shrinkProgress = (progress - 0.3) / 0.3;
      scale = Vector2.all(1.2 - shrinkProgress * 0.2); // 1.2 -> 1.0
    } else {
      // Mantém tamanho normal
      scale = Vector2.all(1.0);
    }

    // Verifica se deve mudar o número
    if (elapsedTime >= countDuration) {
      elapsedTime = 0;
      currentCount--;

      if (currentCount > 0) {
        text = currentCount.toString();
        scale = Vector2.all(0.5); // Reset da escala
      } else {
        // Mostrar "GO!"
        text = "GO!";
        textRenderer = TextPaint(
          style: GoogleFonts.lilitaOne(
            fontSize: 140.0,
            color: const Color(0xFF11AC00),
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(
                blurRadius: 30.0,
                color: Colors.black,
                offset: Offset(5.0, 5.0),
              ),
              const Shadow(
                blurRadius: 15.0,
                color: Colors.white,
                offset: Offset(0, 0),
              ),
            ],
          ),
        );
        scale = Vector2.all(0.5);

        // Agendar remoção após 1 segundo
        Future.delayed(const Duration(seconds: 1), () {
          isComplete = true;
          onComplete();
          removeFromParent();
        });
      }
    }
  }
}
