import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleDarkMode extends SettingsEvent {
  final bool enabled;
  ToggleDarkMode(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class ToggleAutoSave extends SettingsEvent {
  final bool enabled;
  ToggleAutoSave(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class LogoutPressed extends SettingsEvent {}
