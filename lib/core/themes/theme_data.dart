import 'package:flutter/material.dart';

import 'colors/app_colors_theme.dart';

final themeData = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: const Color(0xFF44BD6E),
  useMaterial3: true,
  extensions: const [
    AppColorsTheme(
      black: Color(0xFF000000),
      white: Colors.white,
      green: Color(0xFF44BD6E),
      darkGreen: Color(0xFF1E4D5F),
      greenLight: Color(0xFF2B9690),
    ),
  ],
);
