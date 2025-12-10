import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/core/navigation/navigation_service.dart';
import 'package:pixel_adventure/core/services/snack_bar/snack_bar.dart';
import 'package:pixel_adventure/core/themes/extensions/color_theme_extension.dart';
import 'package:pixel_adventure/core/themes/extensions/responsive_extension.dart';
import 'package:pixel_adventure/core/widgets/loading_widget.dart';
import 'package:pixel_adventure/modules/sign_in/interactor/controllers/sign_in_controller.dart';
import 'package:pixel_adventure/modules/sign_in/interactor/state/sign_in_state.dart';

class SignInPage extends StatefulWidget {
  final SignInController signInController;

  const SignInPage({
    super.key,
    required this.signInController,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final passwordTextEditingController = TextEditingController();
  final userTextEditingController = TextEditingController();
  final formGlobalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.signInController.addListener(_onSignInStateChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        
      },
    );
  }

  void _onSignInStateChanged() {
    final state = widget.signInController.value;

    if (state is LoggedState) {
      NavigationService.navigate(
        context: context,
        route: '/menu',
      );
    }

    if (state is SignInFailure) {
      SnackBarService.showError(
        context: context,
        message: state.appException!.message,
      );
    }
  }

  @override
  void dispose() {
    widget.signInController.removeListener(_onSignInStateChanged);
    passwordTextEditingController.dispose();
    userTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;
    final padding = context.padding;
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ValueListenableBuilder(
          valueListenable: widget.signInController,
          builder: (context, state, child) {
            return Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff105DE5),
                  Color(0xFF0471FF),
                ],
              )),
              height: screenSize.height,
              width: screenSize.width,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 33.w,
                ),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: screenSize.height - (padding.bottom + padding.top),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Text(
                              "INFORME SEU NICK",
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
                              "INFORME SEU NICK",
                              style: GoogleFonts.lilitaOne(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Transform(
                            transform: Matrix4.skewX(-0.1),
                            child: TextField(
                              controller: userTextEditingController,
                              cursorColor: Color(0xffFD9B0E), //
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lilitaOne(
                                  color: Color(0xffFD9B0E), fontSize: 24),
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(color: Colors.white),
                                fillColor: const Color(0xff082F73),
                                isCollapsed: false,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 40.h,
                                ),
                                isDense: true,
                                filled: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        // SignInCardWidget(
                        //   passwordTextEditingController:
                        //       passwordTextEditingController,
                        //   userTextEditingController: userTextEditingController,
                        //   onUserChanged: (value) =>
                        //       widget.signInController.setEmail(value),
                        //   onPasswordChanged: (value) => widget.signInController
                        //       .setPassword(Password(value)),
                        //   isLoading: state.isLoading,
                        //   onEnterPressed:
                        //       state.isLoading || !state.signInModel.isValid
                        //           ? () => setState(() {})
                        //           : () => widget.signInController.doSignIn(),
                        // ),
                        GestureDetector(
                          onTap: state.isLoading ||
                                  userTextEditingController.text.isEmpty
                              ? () => setState(() {})
                              : () => widget.signInController.doSignInNick(
                                  nick: userTextEditingController.text),
                          child: Transform(
                            transform: Matrix4.skewX(
                                -0.1), // valor negativo inclina para a esquerda
                            child: Container(
                              width: 240,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEC643),
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.black, width: 3),
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
                                      child: Visibility(
                                    visible: state.isLoading,
                                    replacement: Stack(
                                      children: [
                                        Text(
                                          "ENTRAR",
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
                                          "ENTRAR",
                                          style: GoogleFonts.lilitaOne(
                                            fontSize: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: const LoadingWidget(),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.only(
                        //     bottom: 24.0.h,
                        //   ),
                        //   child: TextButton(
                        //     onPressed: () {
                        //       // widget.launchService
                        //       //     .launchWeb(url: 'http://www.google.com.br');
                        //     },
                        //     child: TextWidget(
                        //       'Política de privacidade',
                        //       colorText: context.appColors.white,
                        //       fontSize: 30.p,
                        //       fontWeight: FontWeight.w400,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
