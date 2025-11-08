import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../services/settings_api_service.dart';
import '../../auth/services/cache_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsApiService api;
  final CacheService cache;

  SettingsBloc({SettingsApiService? apiService, CacheService? cacheService})
    : api = apiService ?? SettingsApiService(baseUrl: "http://10.0.2.2:7777"),
      cache = cacheService ?? CacheService(),
      super(const SettingsState()) {
    on<SettingsAutoSaveReceipt>(_onAutoSaveReceipt);
  }

  /// Handle auto-save receipt preference
  FutureOr<void> _onAutoSaveReceipt(SettingsAutoSaveReceipt event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    try {
      // Get token from cache
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(status: SettingsStatus.error, errorMessage: 'No authentication token found. Please login.'),
        );
        return;
      }

      // Check if token is expired
      if (token.isExpired) {
        emit(state.copyWith(status: SettingsStatus.error, errorMessage: 'Session expired. Please login again.'));
        return;
      }

      // Call API to set auto-save preference
      final result = await api.setAutoSaveReceipt(token.accessToken, event.enabled);

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: SettingsStatus.success,
            message: result['message'] ?? 'Receipt auto-save ${event.enabled ? 'enabled' : 'disabled'} successfully',
            autoSaveReceipt: event.enabled,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: SettingsStatus.error,
            errorMessage: result['message'] ?? 'Failed to update auto-save preference',
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to update auto-save preference';
      if (e is SettingsApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      print('❌ SettingsBloc error: $errorMsg');

      emit(state.copyWith(status: SettingsStatus.error, errorMessage: errorMsg));
    }
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}
