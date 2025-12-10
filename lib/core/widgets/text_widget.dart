

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_adventure/core/themes/extensions/color_theme_extension.dart';
import 'package:pixel_adventure/core/themes/extensions/responsive_extension.dart';


class TextWidget extends StatelessWidget {
  final String text;
  final double? fontSize;
  final TextAlign? align;
  final Color? colorText;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  static TextStyle fontMontserrat = GoogleFonts.montserrat();

  const TextWidget(
    this.text, {
    super.key,
    this.align,
    this.fontSize,
    this.colorText,
    this.fontWeight,
    this.overflow,
    this.decoration,
  });

  factory TextWidget.cardTitle(
    String label, {
    Color? color,
  }) {
    return TextWidget(
      label,
      fontSize: 18.p,
      fontWeight: FontWeight.bold,
      colorText: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStyle = GoogleFonts.montserrat(
      fontSize: fontSize,
      color: colorText ?? context.appColors.black,
      fontWeight: fontWeight,
      decoration: decoration,
    );

    return TweenAnimationBuilder<double>(
      duration: const Duration(
        milliseconds: 600,
      ),
      curve: Curves.fastEaseInToSlowEaseOut,
      tween: Tween(begin: 0, end: 1.0),
      child: Text(
        text,
        textAlign: align,
        style: currentStyle,
        overflow: overflow,
      ),
      builder: (context, value, child) {
        return Transform.scale(
          scaleX: value,
          child: child,
        );
      },
    );
  }
}