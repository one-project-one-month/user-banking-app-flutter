import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Scan extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPickImage;
  final String text;
  final String svgAssetPath;

  const Scan({
    super.key,
    required this.imagePath,
    required this.onPickImage,
    required this.text,
    required this.svgAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8),
              child: Center(
                child:
                    imagePath == null
                        ? SvgPicture.asset(
                          svgAssetPath,
                          fit: BoxFit.contain,
                          width: 100,
                          height: 100,
                        )
                        : Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
