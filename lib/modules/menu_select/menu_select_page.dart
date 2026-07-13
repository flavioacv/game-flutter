import 'package:flame/components.dart' hide Matrix4;
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/core/constants/routes/app_routes.dart';
import 'package:pixel_adventure/core/navigation/navigation_service.dart';
import 'package:pixel_adventure/core/themes/extensions/color_theme_extension.dart';
import 'package:pixel_adventure/core/widgets/loading_widget.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  _CharacterSelectionScreenState createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final List<String> characters = [
    'Ninja Frog',
    'Mask Dude',
    'Pink Man',
    'Virtual Guy',
    'Ninja Dude'

  ];
  final ValueNotifier<int> selectedCharacterIndex = ValueNotifier<int>(0);
  late final List<CharacterAnimationGame> _characterGames;

  @override
  void initState() {
    super.initState();
    _characterGames = characters.map((c) => CharacterAnimationGame(c)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0447BB),
              Color(0xFF0471FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Carrossel com uma página por personagem
              SizedBox(
                height: 200,
                child: ValueListenableBuilder<int>(
                  valueListenable: selectedCharacterIndex,
                  builder: (context, value, _) {
                    return PageView.builder(
                      itemCount: characters.length,
                      controller: PageController(viewportFraction: 0.2),
                      onPageChanged: (index) =>
                          selectedCharacterIndex.value = index,
                      itemBuilder: (context, index) {
                        final isSelected =
                            selectedCharacterIndex.value == index;
                        return Center(
                          child: Transform(
                            transform: Matrix4.skewX(-0.1),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      !isSelected ? Colors.black : Colors.white,
                                  width: 3,
                                ),
                                color: Color(0xffF38427),
                              ),
                              // padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Spacer(),
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: GameWidget(
                                      loadingBuilder: (context) =>
                                          const LoadingWidget(),
                                      backgroundBuilder: (context) =>
                                          Container(color: Color(0xffF38427)),
                                      game: _characterGames[index],
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff39283A),
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    height: 40,
                                    width: context.screenSize.width,
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          Text(
                                            characters[index],
                                            style: GoogleFonts.lilitaOne(
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 3
                                                ..color = Colors.black,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black,
                                                  offset: Offset(0, 3),
                                                  blurRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            characters[index],
                                            style: GoogleFonts.lilitaOne(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  final selected = characters[selectedCharacterIndex.value];
                  print("Personagem escolhido: $selected");
                  NavigationService.pushNamed(
                    arguments: {'selected': selected},
                    context: context,
                    route: AppRoutes.roomListRoute,
                  );
                },
                child: Transform(
                  transform: Matrix4.skewX(
                      -0.1), // valor negativo inclina para a esquerda
                  child: Container(
                    width: 240,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEC643),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: Stack(
                      children: [
                        // sombra inferior marrom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFA6552D),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        // luz no topo
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBEF44),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        // texto
                        Center(
                            child: Stack(
                          children: [
                            Text(
                              "PLAY",
                              style: GoogleFonts.lilitaOne(
                                fontSize: 32,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 3
                                  ..color = Colors.black,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(0, 3),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "PLAY",
                              style: GoogleFonts.lilitaOne(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterAnimationGame extends FlameGame {
  final String character;
  late SpriteAnimationComponent characterAnimation;

  CharacterAnimationGame(this.character);

  @override
  Future<void> onLoad() async {
    await _loadFallbackAnimation();
    return super.onLoad();
  }

  Future<void> _loadFallbackAnimation() async {
    int amount = 11; // Default for Idle animation
    Vector2 scale = Vector2(3, 3);

    // Load sprite sheet
    await images.loadAll([
      'Main Characters/$character/Idle (32x32).png',
    ]);

    // Create animation component
    characterAnimation = SpriteAnimationComponent(
        animation: _spriteAnimation('Idle', amount),
        position: Vector2(0, 0),
        scale: scale);

    add(characterAnimation);
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
