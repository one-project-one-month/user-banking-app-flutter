import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==============================================================================
// RESPONSIVE UTILITIES
// ==============================================================================

/// Device type enum
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Enhanced responsive utility system
class ResponsiveUtils {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 900) {
      return DeviceType.tablet;
    } else if (width < 1200) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  static double getScaleFactor(BuildContext context) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => 1.0,
      DeviceType.tablet => 1.3,
      DeviceType.desktop => 1.6,
      DeviceType.largeDesktop => 2.0,
    };
  }

  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    return switch (deviceType) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.desktop => desktop ?? tablet ?? mobile,
      DeviceType.largeDesktop => largeDesktop ?? desktop ?? tablet ?? mobile,
    };
  }

  static double fontSize(BuildContext context, double baseSize, {double? minSize, double? maxSize}) {
    final scaled = baseSize * getScaleFactor(context);
    if (minSize != null && scaled < minSize) return minSize;
    if (maxSize != null && scaled > maxSize) return maxSize;
    return scaled;
  }

  static double spacing(BuildContext context, double baseSpacing) {
    return baseSpacing * getScaleFactor(context);
  }

  static EdgeInsets padding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final scale = getScaleFactor(context);
    if (all != null) return EdgeInsets.all(all * scale);
    return EdgeInsets.only(
      left: (left ?? horizontal ?? 0) * scale,
      top: (top ?? vertical ?? 0) * scale,
      right: (right ?? horizontal ?? 0) * scale,
      bottom: (bottom ?? vertical ?? 0) * scale,
    );
  }

  /// Returns a scaled BorderRadius
  static BorderRadius borderRadius(BuildContext context, double radius) {
    return BorderRadius.circular(radius * getScaleFactor(context));
  }

  /// Returns just the scaled radius value (useful for custom shapes)
  static double borderRadiusValue(BuildContext context, double radius) {
    return radius * getScaleFactor(context);
  }

  static double iconSize(BuildContext context, double baseSize, {double? minSize, double? maxSize}) {
    final scaled = baseSize * getScaleFactor(context);
    if (minSize != null && scaled < minSize) return minSize;
    if (maxSize != null && scaled > maxSize) return maxSize;
    return scaled;
  }

  static bool isMobile(BuildContext context) => getDeviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.largeDesktop;
  }

  static double formWidth(BuildContext context) {
    return responsive(
      context: context,
      mobile: MediaQuery.of(context).size.width - spacing(context, 40),
      tablet: 500,
      desktop: 600,
    );
  }

  static double buttonHeight(BuildContext context) {
    return responsive(context: context, mobile: 48, tablet: 52, desktop: 56);
  }

  static EdgeInsets scrollPadding(BuildContext context) {
    return EdgeInsets.only(
      left: spacing(context, 20),
      top: spacing(context, 20),
      right: spacing(context, 20),
      bottom: spacing(context, 20) + MediaQuery.of(context).viewInsets.bottom,
    );
  }
}

/// Extension on BuildContext — NOW INCLUDES borderRadius!
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  double fontSize(double baseSize, {double? minSize, double? maxSize}) =>
      ResponsiveUtils.fontSize(this, baseSize, minSize: minSize, maxSize: maxSize);

  double spacing(double baseSpacing) => ResponsiveUtils.spacing(this, baseSpacing);

  double iconSize(double baseSize, {double? minSize, double? maxSize}) =>
      ResponsiveUtils.iconSize(this, baseSize, minSize: minSize, maxSize: maxSize);

  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => ResponsiveUtils.padding(
    this,
    all: all,
    horizontal: horizontal,
    vertical: vertical,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );

  /// Now you can use: context.borderRadius(8)
  BorderRadius borderRadius(double radius) => ResponsiveUtils.borderRadius(this, radius);

  /// Or just get the number: context.borderRadiusValue(12)
  double borderRadiusValue(double radius) => ResponsiveUtils.borderRadiusValue(this, radius);
}