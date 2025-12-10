
import 'package:flutter/material.dart';
import 'package:pixel_adventure/core/themes/colors/app_colors_theme.dart';

/// This file contains extensions for [BuildContext] and a function to convert a hex string to a [Color].
///
/// The [ColorThemeExtension] extension provides convenient access to the [AppColorsTheme], [Size], and [EdgeInsets] of the current [BuildContext].
///
/// The [ColorRGB] extension provides a way to convert a hex string to a [Color] object.
///
/// The [hexStringToColor] function takes a hex string and returns a [Color] object.
///
extension ColorThemeExtension on BuildContext {
  AppColorsTheme get appColors => Theme.of(this).extension<AppColorsTheme>()!;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
}
