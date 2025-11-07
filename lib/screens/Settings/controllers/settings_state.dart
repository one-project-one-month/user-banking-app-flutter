import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String? message;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.message,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    String? message,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == SettingsStatus.loading;
  bool get isSuccess => status == SettingsStatus.success;
  bool get hasError => status == SettingsStatus.failure;

  @override
  List<Object?> get props => [status, message, errorMessage];
}

