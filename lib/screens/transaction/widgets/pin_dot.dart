import 'package:flutter/material.dart';

class PinDot extends StatelessWidget {
  final bool isFilled;
  final double size;

  const PinDot({super.key, this.isFilled = false, this.size = 14.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? const Color(0xFF0A3D62) : Colors.transparent,
        border: Border.all(
          color: isFilled ? const Color(0xFF0A3D62) : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
    );
  }
}
