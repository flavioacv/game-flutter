// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/core/services/local_storage/local_storage_service.dart';
import 'package:pixel_adventure/pixel_adventure.dart';
import 'package:pixel_adventure/screens/exit_confirmation_overlay.dart';
import 'package:pixel_adventure/screens/main_menu.dart';

class GamePage extends StatefulWidget {
  final LocalStorageService localStorageService;
  final String characterSelected;
  final String roomId;

  const GamePage({
    super.key,
    required this.localStorageService,
    required this.characterSelected,
    required this.roomId,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return GameWidget(
      overlayBuilderMap: {
        'MainMenu': (BuildContext context, PixelAdventure game) {
          return MainMenu(game: game);
        },
        'ExitConfirmation': (BuildContext context, PixelAdventure game) {
          return ExitConfirmationOverlay(game: game);
        },
      },
      initialActiveOverlays: const ['MainMenu'],
      game: PixelAdventure(
          characterSelected: widget.characterSelected,
          localStorageService: widget.localStorageService,
          roomId: widget.roomId,
          widthScreen: MediaQuery.of(context).size.width,
          heightScreen: MediaQuery.of(context).size.height),
    );
  }
}
