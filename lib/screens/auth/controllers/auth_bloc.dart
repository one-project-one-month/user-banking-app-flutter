import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService api;
  final CacheService cache;

  AuthBloc({ApiService? apiService, CacheService? cacheService})
    : api =
          apiService ??
          ApiService(baseUrl: "https://banking-dummy-backend.onrender.com"),
      cache = cacheService ?? CacheService(),
      super(const AuthState()) {
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLoginWithCredentials>(_onLoginWithCredentials);
    on<AuthRequestOTP>(_onRequestOTP);
    on<AuthConfirmOTP>(_onConfirmOTP);
    on<AuthFetchRegistrationOptions>(_onFetchRegistrationOptions);
    on<AuthCreatePassword>(_onCreatePassword);
  }

  FutureOr<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = await api.register(event.payload);
      await cache.saveToken(token);
      // optionally save user info if present in payload
      if (event.payload.isNotEmpty) await cache.saveUser(event.payload);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      String msg = 'Registration failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  FutureOr<void> _onRequestOTP(
    AuthRequestOTP event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final ok = await api.requestOtp(event.payload);
      if (ok) {
        emit(state.copyWith(status: AuthStatus.success, message: 'OTP sent'));
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: 'Failed to request OTP',
          ),
        );
      }
    } catch (e) {
      String msg = 'Failed to request OTP';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  FutureOr<void> _onConfirmOTP(
    AuthConfirmOTP event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = await api.confirmOtp(event.destination, event.code);
      await cache.saveToken(token);
      emit(
        state.copyWith(status: AuthStatus.success, message: 'OTP confirmed'),
      );
    } catch (e) {
      String msg = 'OTP confirmation failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  FutureOr<void> _onCreatePassword(
    AuthCreatePassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final ok = await api.createPassword(
        // event.destination, event.code,
        event.password,
      );
      if (ok) {
        // emit success for create password
        emit(
          state.copyWith(
            status: AuthStatus.success,
            message: 'Password created',
          ),
        );
        // after successful password creation fetch registration options template
        add(AuthFetchRegistrationOptions());
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            message: 'Failed to create password',
          ),
        );
      }
    } catch (e) {
      String msg = 'Create password failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  FutureOr<void> _onFetchRegistrationOptions(
    AuthFetchRegistrationOptions event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final options = await api.fetchRegistrationOptions();
      // cache the raw json for later use by the UI
      await cache.saveRegistrationOptions(options.toJson());
      emit(
        state.copyWith(
          status: AuthStatus.success,
          message: 'Registration template fetched',
        ),
      );
    } catch (e) {
      String msg = 'Failed to fetch registration template';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  FutureOr<void> _onLoginWithCredentials(
    AuthLoginWithCredentials event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final token = await api.login(event.email, event.password);
      await cache.saveToken(token);
      emit(state.copyWith(status: AuthStatus.success));
    } catch (e) {
      String msg = 'Login failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }
}
