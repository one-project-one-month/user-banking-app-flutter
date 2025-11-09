import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String? message;
  final String? errorMessage;
  final bool autoSaveReceipt;
  final bool darkMode;
  final bool autoSave;
  final bool loading;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.message,
    this.errorMessage,
    this.autoSaveReceipt = false,
    required this.darkMode,
    required this.autoSave,
    this.loading = false,
  });

  factory SettingsState.initial() => const SettingsState(darkMode: true, autoSave: true, loading: false);

  SettingsState copyWith({
    SettingsStatus? status,
    String? message,
    String? errorMessage,
    bool? autoSaveReceipt,
    bool? darkMode,
    bool? autoSave,
    bool? loading,
  }) {
    return SettingsState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      autoSaveReceipt: autoSaveReceipt ?? this.autoSaveReceipt,
      darkMode: darkMode ?? this.darkMode,
      autoSave: autoSave ?? this.autoSave,
      loading: loading ?? this.loading,
    );
  }

  bool get isLoading => status == SettingsStatus.loading;
  bool get isSuccess => status == SettingsStatus.success;
  bool get hasError => status == SettingsStatus.error;

  @override
  List<Object?> get props => [status, message, errorMessage, autoSaveReceipt, darkMode, autoSave, loading];
}
