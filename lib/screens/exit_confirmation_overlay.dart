import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

/// Overlay de confirmação para sair do jogo
class ExitConfirmationOverlay extends StatelessWidget {
  final PixelAdventure game;

  const ExitConfirmationOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF211F30),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white24,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone
              const Icon(
                Icons.exit_to_app,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                'Sair da Partida?',
                style: GoogleFonts.lilitaOne(
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Mensagem
              Text(
                'Você será desconectado da sala',
                style: GoogleFonts.lilitaOne(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Botões
              Row(
                children: [
                  // Botão Cancelar
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        game.overlays.remove('ExitConfirmation');
                        game.resumeEngine();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.lilitaOne(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Botão Sair
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        game.overlays.remove('ExitConfirmation');
                        await game.leaveRoom();

                        // Voltar para lista de salas
                        if (navigator.mounted) {
                          navigator.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Sair',
                        style: GoogleFonts.lilitaOne(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
