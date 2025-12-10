import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/components/player.dart';

/// Componente de feedback visual do Kina
/// Mostra mensagens na tela quando o jogador acerta kina
class KinaFeedback extends TextComponent with HasGameRef {
  final Player player;

  KinaFeedback({required this.player})
      : super(
          text: '',
          textRenderer: TextPaint(
            style: GoogleFonts.pressStart2p(
              fontSize: 12.0,
              color: const Color(0xFFFFD700), // Dourado
              shadows: [
                Shadow(
                  color: const Color(0xFF000000),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          priority: 1000, // Sempre no topo
        );

  @override
  FutureOr<void> onLoad() {
    position = Vector2(10, 40); // Posição fixa na tela
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Atualizar texto baseado no feedback do player
    if (player.kinaFeedback.isNotEmpty) {
      text = player.kinaFeedback;

      // Mudar cor baseado no tipo
      if (player.kinaFeedback.contains('SUPER')) {
        textRenderer = TextPaint(
          style: GoogleFonts.pressStart2p(
            fontSize: 14.0,
            color: const Color(0xFFFF1493), // Rosa choque para super kina
            shadows: [
              Shadow(
                color: const Color(0xFF000000),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        );
      } else {
        textRenderer = TextPaint(
          style: GoogleFonts.pressStart2p(
            fontSize: 12.0,
            color: const Color(0xFFFFD700), // Dourado para kina normal
            shadows: [
              Shadow(
                color: const Color(0xFF000000),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        );
      }
    } else {
      text = '';
    }
  }
}
