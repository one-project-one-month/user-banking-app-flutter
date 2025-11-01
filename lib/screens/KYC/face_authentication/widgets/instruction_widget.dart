import 'package:flutter/material.dart';

class InstructionWidget extends StatelessWidget {
  final String text;

  const InstructionWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        text,
        style: const TextStyle(color: const Color(0xFF0A3D62), fontSize: 15, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
