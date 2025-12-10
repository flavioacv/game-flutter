import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color borderColor;
  final IconData? icon;

  const PixelButton({
    super.key,
    required this.text,
    required this.color,
    required this.borderColor,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                offset: Offset(2, 3),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: GoogleFonts.pressStart2p(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 12),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
