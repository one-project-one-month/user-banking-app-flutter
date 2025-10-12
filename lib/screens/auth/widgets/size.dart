import 'package:flutter/material.dart';

class CommonSize {
  /// Automatically returns a scale factor based on screen width.
  static double _scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      // Phone
      return 1.0;
    } else if (width >= 600 && width < 900) {
      // Small tablet
      return 1.3;
    } else if (width >= 900 && width < 1200) {
      // Large tablet
      return 1.6;
    } else {
      // Desktop
      return 2.0;
    }
  }

  /// Returns a responsive size value.
  static double size(BuildContext context, double baseSize) {
    return baseSize * _scale(context);
  }

  // --- Predefined sizes (2 → 120) ---
  static double s2(BuildContext context) => size(context, 2);
  static double s4(BuildContext context) => size(context, 4);
  static double s6(BuildContext context) => size(context, 6);
  static double s8(BuildContext context) => size(context, 8);
  static double s10(BuildContext context) => size(context, 10);
  static double s12(BuildContext context) => size(context, 12);
  static double s14(BuildContext context) => size(context, 14);
  static double s16(BuildContext context) => size(context, 16);
  static double s18(BuildContext context) => size(context, 18);
  static double s20(BuildContext context) => size(context, 20);
  static double s24(BuildContext context) => size(context, 24);
  static double s28(BuildContext context) => size(context, 28);
  static double s32(BuildContext context) => size(context, 32);
  static double s36(BuildContext context) => size(context, 36);
  static double s40(BuildContext context) => size(context, 40);
  static double s48(BuildContext context) => size(context, 48);
  static double s56(BuildContext context) => size(context, 56);
  static double s64(BuildContext context) => size(context, 64);
  static double s72(BuildContext context) => size(context, 72);
  static double s80(BuildContext context) => size(context, 80);
  static double s96(BuildContext context) => size(context, 96);
  static double s100(BuildContext context) => size(context, 100);
  static double s120(BuildContext context) => size(context, 120);
}
