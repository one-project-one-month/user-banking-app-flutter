import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.width = 120,
    this.height = 120,
    this.borderRadius = 24,
    this.fit = BoxFit.fill,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            showShadow
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        "assets/logo/flypay.png",
        fit: fit,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
