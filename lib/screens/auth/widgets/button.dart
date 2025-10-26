import 'package:flutter/material.dart';

Widget customElevatedButton({
  required String text,
  required VoidCallback onPressed,

  bool isLoading = false,
  Color? color,
  Color? textColor,
  double? height,
  double? width,
  double? fontSize,
  FontWeight? fontWeight,
  BorderRadius? borderRadius,
}) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color ?? Colors.blue),
      minimumSize: WidgetStateProperty.all(
        Size(width ?? double.infinity, height ?? 48),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    ),
    onPressed: isLoading ? null : onPressed,
    child:
        isLoading
            ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
            : Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight ?? FontWeight.normal,
                color: textColor ?? Colors.black,
              ),
            ),
  );
}
