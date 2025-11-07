import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_event.dart';
import 'user_state.dart';
import '../services/user_api_service.dart';
import '../../auth/services/cache_service.dart';
import '../models/user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserApiService api;
  final CacheService cache;

  UserBloc({UserApiService? apiService, CacheService? cacheService})
    : api = apiService ?? UserApiService(baseUrl: "http://10.0.2.2:7777"),
      cache = cacheService ?? CacheService(),
      super(const UserState()) {
    on<UserLoadData>(_onLoadData);
    on<UserRefreshData>(_onRefreshData);
    on<UserUpdateBalance>(_onUpdateBalance);
    on<UserClearData>(_onClearData);
  }

  FutureOr<void> _onLoadData(UserLoadData event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      // Get token from cache
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: UserStatus.error, errorMessage: 'No authentication token found. Please login.'));
        return;
      }

      // Check if token is expired
      if (token.isExpired) {
        emit(state.copyWith(status: UserStatus.error, errorMessage: 'Session expired. Please login again.'));
        return;
      }

      // Fetch user data from API
      final user = await api.getCurrentUser(token.accessToken);

      // Save to cache
      await cache.saveUser(user.toJson());

      emit(state.copyWithUser(status: UserStatus.loaded, user: user, errorMessage: null));
    } catch (e) {
      String errorMsg = 'Failed to load user data';
      if (e is UserApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      print('❌ UserBloc error: $errorMsg');

      // Try to load from cache as fallback
      final cachedUser = await cache.getUser();
      if (cachedUser != null) {
        try {
          final user = User.fromJson(cachedUser);
          emit(state.copyWithUser(status: UserStatus.loaded, user: user, errorMessage: 'Using cached data. $errorMsg'));
          return;
        } catch (_) {}
      }

      emit(state.copyWith(status: UserStatus.error, errorMessage: errorMsg));
    }
  }

  /// Refresh user data (pull to refresh)
  FutureOr<void> _onRefreshData(UserRefreshData event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.refreshing));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: UserStatus.error, errorMessage: 'No authentication token found'));
        return;
      }

      final user = await api.getCurrentUser(token.accessToken);
      await cache.saveUser(user.toJson());

      emit(state.copyWithUser(status: UserStatus.loaded, user: user, errorMessage: null));
    } catch (e) {
      String errorMsg = 'Failed to refresh data';
      if (e is UserApiException) {
        errorMsg = e.message;
      }

      emit(state.copyWith(status: UserStatus.error, errorMessage: errorMsg));
    }
  }

  /// Update balance locally (after transaction)
  FutureOr<void> _onUpdateBalance(UserUpdateBalance event, Emitter<UserState> emit) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(currentBalance: event.newBalance);

    // Update cache
    await cache.saveUser(updatedUser.toJson());

    emit(state.copyWithUser(status: UserStatus.loaded, user: updatedUser));
  }

  /// Clear user data (logout)
  FutureOr<void> _onClearData(UserClearData event, Emitter<UserState> emit) async {
    await cache.clearAll();
    emit(const UserState(status: UserStatus.initial));
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}
