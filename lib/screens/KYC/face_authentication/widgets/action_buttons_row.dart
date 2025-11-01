import 'package:flutter/material.dart';
import 'circular_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final bool isAuthenticating;
  final VoidCallback onStartStop;
  final VoidCallback? onCancel;
  final VoidCallback onInfo;

  const ActionButtonsRow({
    super.key,
    required this.isAuthenticating,
    required this.onStartStop,
    this.onCancel,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircularButton(
          size: 60,
          backgroundColor: Colors.grey[200]!,
          icon: Icons.close,
          onTap: isAuthenticating ? onCancel : null,
        ),
        CircularButton(
          size: 80,
          backgroundColor: const Color(0xFF0A3D62),
          icon: isAuthenticating ? Icons.stop : Icons.camera_alt,
          iconColor: Colors.white,
          iconSize: 36,
          onTap: onStartStop,
        ),
        CircularButton(
          size: 60,
          backgroundColor: Colors.grey[200]!,
          icon: Icons.info_outline,
          onTap: onInfo,
        ),
      ],
    );
  }
}