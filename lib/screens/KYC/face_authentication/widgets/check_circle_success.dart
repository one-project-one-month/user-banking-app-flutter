import 'package:flutter/material.dart';

class CheckCircleSuccess extends StatelessWidget {
  const CheckCircleSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Outermost light-gray ring
        Container(
          width: 160,
          height: 160,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE5E8ED), // light gray
          ),
        ),

        // 2. Medium-blue ring
        Container(
          width: 136,
          height: 136,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF6B8CAE), // medium blue-gray
          ),
        ),

        // 3. Dark-blue inner circle
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0A3D62), // your brand dark blue
          ),
        ),

        // 4. Checkmark with thin white border
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 32),
        ),
      ],
    );
  }
}
