import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final double size;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: CameraPreview(controller),
      ),
    );
  }
}