import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../models/token.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLoginWithGoogle>(_onLoginWithGoogle);
    on<AuthLoginWithCredentials>(_onLoginWithCredentials);
  }

  FutureOr<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    // Here you would call your repository / API. We'll simulate success.
    // create a fake token that expires in 1 hour
    final token = Token(
      accessToken:
          'register_simulated_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', json.encode(token.toJson()));
    emit(state.copyWith(status: AuthStatus.success));
  }

  FutureOr<void> _onLoginWithGoogle(
    AuthLoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    final token = Token(
      accessToken:
          'google_simulated_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', json.encode(token.toJson()));
    emit(state.copyWith(status: AuthStatus.success));
  }

  FutureOr<void> _onLoginWithCredentials(
    AuthLoginWithCredentials event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await Future.delayed(const Duration(seconds: 1));
    // naive check
    if (event.email == 'test@example.com' && event.password == 'password') {
      final token = Token(
        accessToken:
            'cred_simulated_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', json.encode(token.toJson()));
      emit(state.copyWith(status: AuthStatus.success));
    } else {
      emit(state.copyWith(status: AuthStatus.failure, message: 'Invalid cred'));
    }
  }
}
