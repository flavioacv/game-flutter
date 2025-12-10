import 'package:flutter/material.dart';

/// A class that defines the color scheme for the Eleven Dash App.
///
/// This class extends the `ThemeExtension` class and provides a set of colors
/// that can be used to style the app's UI elements. The colors are defined as
/// instance variables and can be accessed directly. The class also provides
/// methods to create copies of the theme with modified colors and to interpolate
/// between two themes.
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color black;
  final Color white;
  final Color green;
  final Color greenLight;
  final Color darkGreen;

  const AppColorsTheme({
    required this.black,
    required this.white,
    required this.green,
    required this.darkGreen,
    required this.greenLight,
  });

  @override
  ThemeExtension<AppColorsTheme> copyWith({
    Color? black,
    Color? white,
    Color? green,
    Color? darkGreen,
    Color? greenLight,
  }) {
    return AppColorsTheme(
      black: black ?? this.black,
      white: white ?? this.white,
      green: green ?? this.green,
      darkGreen: darkGreen ?? this.darkGreen,
      greenLight: greenLight ?? this.greenLight,
    );
  }

  @override
  AppColorsTheme lerp(AppColorsTheme? other, double t) {
    return AppColorsTheme(
      black: Color.lerp(
        black,
        other?.black,
        t,
      )!,
      white: Color.lerp(
        white,
        other?.white,
        t,
      )!,
      green: Color.lerp(
        green,
        other?.green,
        t,
      )!,
      darkGreen: Color.lerp(
        darkGreen,
        other?.darkGreen,
        t,
      )!,
      greenLight: Color.lerp(
        greenLight,
        other?.greenLight,
        t,
      )!,
    );
  }
}
