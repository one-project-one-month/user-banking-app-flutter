import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String? message;
  final String? errorMessage;
   final bool darkMode;
  final bool autoSave;
  final bool loading;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.message,
    this.errorMessage,
      required this.darkMode,
    required this.autoSave,
   
    this.loading = false,
  });

    factory SettingsState.initial() => SettingsState(
        darkMode: true,
        autoSave: true,
        loading: false,
      );

  SettingsState copyWith({
    SettingsStatus? status,
    String? message,
    String? errorMessage,
     bool? darkMode,
    bool? autoSave,
    bool? loading,
  }) {
    return SettingsState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
            darkMode: darkMode ?? this.darkMode,
      autoSave: autoSave ?? this.autoSave,
   
      loading: loading ?? this.loading,
    );
  }

  bool get isLoading => status == SettingsStatus.loading;
  bool get isSuccess => status == SettingsStatus.success;
  bool get hasError => status == SettingsStatus.failure;

  @override
  List<Object?> get props => [status, message, errorMessage,darkMode, autoSave, loading];
}

