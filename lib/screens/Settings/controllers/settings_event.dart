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

/// Auto Save Receipt
class SettingsAutoSaveReceipt extends SettingsEvent {
  final bool flag;

  const SettingsAutoSaveReceipt(this.flag);

  @override
  List<Object?> get props => [flag];
}

