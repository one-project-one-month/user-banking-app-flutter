import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

/// Shows a top flushbar notification.
/// 
/// [context] is required to show the Flushbar.
/// [message] is the text to display.
/// [backgroundColor] optional, default is Colors.redAccent.
/// [icon] optional, default is error icon.
/// [duration] optional, default 3 seconds.
void customFlushbar({
  required BuildContext context,
  required String message,
  Color backgroundColor = Colors.redAccent,
  Icon? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  Flushbar(
    message: message,
    duration: duration,
    backgroundColor: backgroundColor,
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    flushbarPosition: FlushbarPosition.TOP,
    animationDuration: const Duration(milliseconds: 500),
    icon: icon ?? const Icon(Icons.error, color: Colors.white),
  ).show(context);
}
