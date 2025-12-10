import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class MainMenu extends StatelessWidget {
  final PixelAdventure game;

  const MainMenu({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF211F30), // Dark background matching game
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                'Pixel Adventure',
                style: GoogleFonts.lilitaOne(
                  fontSize: 64.0,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove('MainMenu');
                  game.startCountdown();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11AC00), // Pixel green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'JOGAR',
                  style: GoogleFonts.lilitaOne(
                    fontSize: 32.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botão SAIR
            SizedBox(
              width: 200,
              height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  // Mostrar diálogo de confirmação
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: const Color(0xFF211F30),
                      title: Text(
                        'Sair da Sala?',
                        style: GoogleFonts.lilitaOne(
                          color: Colors.white,
                        ),
                      ),
                      content: Text(
                        'Deseja realmente sair da sala?',
                        style: GoogleFonts.lilitaOne(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.lilitaOne(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: Text(
                            'Sair',
                            style: GoogleFonts.lilitaOne(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    // Sair da sala
                    await game.leaveRoom();

                    // Voltar para a tela anterior (lista de salas)
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'SAIR',
                  style: GoogleFonts.lilitaOne(
                    fontSize: 32.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Optional: Add more buttons here later
          ],
        ),
      ),
    );
  }
}
