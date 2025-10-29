// widgets/face_progress_ring.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_preview_widget.dart';

class FaceProgressRing extends StatelessWidget {
  final CameraController controller;
  final int currentStep;
  final int totalSteps;
  final bool isCompleted;

  const FaceProgressRing({
    super.key,
    required this.controller,
    required this.currentStep,
    required this.totalSteps,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps.clamp(1, totalSteps);
    final bool showCheck = isCompleted || currentStep >= totalSteps;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Outer Progress Ring (Green)
        SizedBox(
          width: 260,
          height: 260,
          child: CircularProgressIndicator(
            value: showCheck ? 1.0 : progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), // GREEN RING
          ),
        ),

        // 2. Inner Camera Preview (250px circle)
        Container(
          width: 250,
          height: 250,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          clipBehavior: Clip.hardEdge,
          child: CameraPreviewWidget(controller: controller),
        ),

        // 3. Checkmark (only when complete)
        if (showCheck)
          Positioned(
            bottom: 8,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 24),
            ),
          ),
      ],
    );
  }
}