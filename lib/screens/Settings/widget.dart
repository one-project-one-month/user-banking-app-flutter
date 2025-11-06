import 'package:flutter/material.dart';
import 'views/settings_view.dart';

/// Simple wrapper to expose Settings screen where other code expects `widget.dart`.
class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
  }
}
