import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Set Transaction PIN
class SettingsSetPin extends SettingsEvent {
  final String pin;

  const SettingsSetPin(this.pin);

  @override
  List<Object?> get props => [pin];
}

/// Change Password
class SettingsChangePassword extends SettingsEvent {
  final String oldPassword;
  final String newPassword;

  const SettingsChangePassword({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}




class LoadSettings extends SettingsEvent {
  /// If true, force reading persisted settings and emit them even on first run.
  /// By default the first app run will persist `SettingsState.initial()` defaults.
  final bool force;

  const LoadSettings({this.force = false});

  @override
  List<Object?> get props => [force];
}

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