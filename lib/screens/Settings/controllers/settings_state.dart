import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String? message;
  final String? errorMessage;
  final bool autoSaveReceipt;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.message,
    this.errorMessage,
    this.autoSaveReceipt = false,
  });

  SettingsState copyWith({SettingsStatus? status, String? message, String? errorMessage, bool? autoSaveReceipt}) {
    return SettingsState(
      status: status ?? this.status,
      message: message,
      errorMessage: errorMessage,
      autoSaveReceipt: autoSaveReceipt ?? this.autoSaveReceipt,
    );
  }

  bool get isLoading => status == SettingsStatus.loading;
  bool get isSuccess => status == SettingsStatus.success;
  bool get hasError => status == SettingsStatus.error;

  @override
  List<Object?> get props => [status, message, errorMessage, autoSaveReceipt];
}
