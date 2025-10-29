import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onTap;

  const CircularButton({
    super.key,
    required this.size,
    required this.backgroundColor,
    required this.icon,
    this.iconColor,
    this.iconSize = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(
            icon,
            color: iconColor ?? Colors.black54,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}