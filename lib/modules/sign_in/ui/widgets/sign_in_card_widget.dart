import 'package:flutter/material.dart';
import 'package:pixel_adventure/core/themes/extensions/color_theme_extension.dart';
import 'package:pixel_adventure/core/themes/extensions/responsive_extension.dart';
import 'package:pixel_adventure/core/types/types.dart';
import 'package:pixel_adventure/core/value_objects/email.dart';
import 'package:pixel_adventure/core/widgets/button_widget.dart';
import 'package:pixel_adventure/core/widgets/loading_widget.dart';
import 'package:pixel_adventure/core/widgets/text_field_widget.dart';
import 'package:pixel_adventure/core/widgets/text_widget.dart';

import '../../../../core/value_objects/password.dart';

class SignInCardWidget extends StatelessWidget {
  final OnChanged<String> onUserChanged;
  final OnChanged<String> onPasswordChanged;
  final VoidCallback? onEnterPressed;
  final bool isLoading;
  final TextEditingController userTextEditingController;
  final TextEditingController passwordTextEditingController;

  const SignInCardWidget({
    super.key,
    required this.onUserChanged,
    required this.onPasswordChanged,
    required this.onEnterPressed,
    required this.isLoading,
    required this.userTextEditingController,
    required this.passwordTextEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.decelerate,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child!,
        );
      },
      child: Container(
        width: context.screenSize.width * 0.7,
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.0.w,
                    ),
                    child: TextFieldWidget(
                      textAlign: TextAlign.start,
                      controller: userTextEditingController,
                      label: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextWidget(
                          'E-mail',
                          fontSize: 30.p,
                          colorText: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onChanged: onUserChanged,
                      validator: (value) {
                        return Email(value!).isValidEmail;
                      },
                      prefixIcon: Icon(
                        Icons.person_2_rounded,
                        size: 10.w,
                        color: context.appColors.black,
                      ),
                    ),
                  ),
                  TextFieldWidget(
                    textAlign: TextAlign.start,
                    controller: passwordTextEditingController,
                    osbscureText: true,
                    label: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextWidget(
                        'Senha',
                        fontSize: 30.p,
                        colorText: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 10.w,
                      color: context.appColors.black,
                    ),
                    onChanged: onPasswordChanged,
                    validator: (value) {
                      return Password(value!).isValidPassword;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: ButtonWidget(
                onPressed: onEnterPressed,
                outlinedBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0.w),
                  ),
                ),
                width: context.screenSize.width * 0.2,
                height: 100.h,
                child: Visibility(
                  visible: isLoading,
                  replacement: TextWidget(
                    'Entrar',
                    fontSize: 30.p,
                    fontWeight: FontWeight.w400,
                    colorText: context.appColors.white,
                  ),
                  child: const LoadingWidget(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
