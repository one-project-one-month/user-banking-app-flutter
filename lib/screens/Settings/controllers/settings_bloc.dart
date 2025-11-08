import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../services/settings_api_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsApiService api;

  SettingsBloc({SettingsApiService? apiService})
      : api = apiService ?? SettingsApiService(),
        super(const SettingsState()) {
    on<SettingsSetPin>(_onSetPin);
    on<SettingsChangePassword>(_onChangePassword);
    on<SettingsAutoSaveReceipt>(_onAutoSaveReceipt);
  }

  /// Set Transaction PIN
  FutureOr<void> _onSetPin(
    SettingsSetPin event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final result = await api.setPin(event.pin);

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: SettingsStatus.success,
            message: result['message'] ?? 'PIN set successfully',
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SettingsStatus.failure,
            errorMessage: result['message'] ?? 'Failed to set PIN',
            message: null,
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to set PIN';
      if (e is SettingsApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: errorMsg,
          message: null,
        ),
      );
    }
  }

  /// Change Password
  FutureOr<void> _onChangePassword(
    SettingsChangePassword event,
    Emitter<SettingsState> emit,
  ) async {
    print('🔐 SettingsBloc: Change password event received');
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      print('🔐 SettingsBloc: Calling API to change password...');
      final result = await api.changePassword(event.oldPassword, event.newPassword);
      print('🔐 SettingsBloc: API call completed, result: ${result['success']}');

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: SettingsStatus.success,
            message: result['message'] ?? 'Password changed successfully',
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SettingsStatus.failure,
            errorMessage: result['message'] ?? 'Failed to change password',
            message: null,
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to change password';
      if (e is SettingsApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: errorMsg,
          message: null,
        ),
      );
    }
  }

  /// Auto Save Receipt
  FutureOr<void> _onAutoSaveReceipt(
    SettingsAutoSaveReceipt event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      final result = await api.autoSaveReceipt(event.flag);

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: SettingsStatus.success,
            message: result['message'] ?? 'Receipt saved successfully',
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SettingsStatus.failure,
            errorMessage: result['message'] ?? 'Failed to save receipt',
            message: null,
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to save receipt';
      if (e is SettingsApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: errorMsg,
          message: null,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}

