import 'package:flutter/material.dart';
import 'package:pixel_adventure/core/themes/extensions/color_theme_extension.dart';
import 'package:pixel_adventure/core/themes/extensions/responsive_extension.dart';

class ButtonWidget extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double width;
  final double height;
  final OutlinedBorder? outlinedBorder;
  final Function()? onPressed;

  const ButtonWidget({
    super.key,
    required this.onPressed,
    this.child = const SizedBox(),
    this.backgroundColor,
    this.width = double.infinity,
    this.height = 48,
    this.outlinedBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          backgroundColor ?? context.appColors.green,
        ),
        shape: outlinedBorder == null
            ? MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.w),
                ),
              )
            : MaterialStateProperty.all(
                outlinedBorder,
              ),
        fixedSize: MaterialStatePropertyAll(
          Size(
            width,
            height,
          ),
        ),
      ),
      child: child,
    );
  }
}
