import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Set auto-save receipt preference
class SettingsAutoSaveReceipt extends SettingsEvent {
  final bool enabled;

  const SettingsAutoSaveReceipt(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
