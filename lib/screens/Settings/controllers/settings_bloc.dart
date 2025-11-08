import 'dart:async';
import 'package:banking_app/screens/Settings/services/settings_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/services/cache_service.dart';
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

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsApiService api;
  static const _kDark = 'settings_dark_mode';
  static const _kAuto = 'settings_auto_save';
  final CacheService cache;

  SettingsBloc({SettingsApiService? apiService, CacheService? cacheService})
      : api = apiService ?? SettingsApiService(),
        cache = cacheService ?? CacheService(),
        super(SettingsState.initial()) {
    // persistence handlers
    on<LoadSettings>(_onLoad);
    on<ToggleDarkMode>(_onToggleDark);
    on<ToggleAutoSave>(_onToggleAuto);
    on<LogoutPressed>(_onLogout);

    // operations
    on<SettingsSetPin>(_onSetPin);
    on<SettingsChangePassword>(_onChangePassword);
    on<SettingsAutoSaveReceipt>(_onAutoSaveReceipt);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    // If app runs for the first time, persist initial defaults then emit them.
    const initKey = '_settings_initialized';
    final initialized = await cache.getBool(initKey);

    if (!event.force && (initialized == null || initialized == false)) {
      // first run: persist initial defaults so subsequent runs pick user selections
      await cache.setBool(_kDark, state.darkMode);
      await cache.setBool(_kAuto, state.autoSave);
      await cache.setBool(initKey, true);
      emit(state);
      return;
    }

    // Either forced load or already initialized – load persisted values
    final dark = await cache.getBool(_kDark) ?? state.darkMode;
    final auto = await cache.getBool(_kAuto) ?? state.autoSave;
    emit(state.copyWith(darkMode: dark, autoSave: auto));
  }

  Future<void> _onToggleDark(ToggleDarkMode event, Emitter<SettingsState> emit) async {
    await cache.setBool(_kDark, event.enabled);
    emit(state.copyWith(darkMode: event.enabled));
  }

  Future<void> _onToggleAuto(ToggleAutoSave event, Emitter<SettingsState> emit) async {
    await cache.setBool(_kAuto, event.enabled);
    emit(state.copyWith(autoSave: event.enabled));
  }

  Future<void> _onLogout(LogoutPressed event, Emitter<SettingsState> emit) async {
    await cache.remove(_kDark);
    await cache.remove(_kAuto);
    emit(SettingsState.initial());
  }

  /// Set Transaction PIN
  FutureOr<void> _onSetPin(
    SettingsSetPin event,
    Emitter<SettingsState> emit,
  ) async {
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
