import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../models/token.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService api;
  final CacheService cache;

  AuthBloc({ApiService? apiService, CacheService? cacheService})
    : api = apiService ?? ApiService(baseUrl: "http://10.0.2.2:7777"),
      cache = cacheService ?? CacheService(),
      super(const AuthState()) {
    on<AuthRequestOTP>(_onRequestOTP);
    on<AuthVerifyOTP>(_onVerifyOTP);
    on<AuthCreatePassword>(_onCreatePassword);
    on<AuthFetchRegistrationOptions>(_onFetchRegistrationOptions);
    on<AuthSubmitPersonalDetails>(_onSubmitPersonalDetails);
    on<AuthLoginWithCredentials>(_onLoginWithCredentials);
  }

  /// Step 1: Request OTP to be sent to email
  FutureOr<void> _onRequestOTP(AuthRequestOTP event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final result = await api.requestOtp(event.email);

      final bool success = result['success'] == true;
      final String message = result['message'] ?? 'Unknown response';
      final String? otpCode = result['data']?.toString();

      if (success) {
        emit(
          state.copyWith(
            status: AuthStatus.success,
            message: message.isNotEmpty ? message : 'OTP sent successfully',
            otpCode: otpCode, // Store OTP for display (in dev/testing)
          ),
        );
      } else {
        emit(
          state.copyWith(status: AuthStatus.failure, message: message.isNotEmpty ? message : 'Failed to request OTP'),
        );
      }
    } catch (e) {
      String msg = 'Failed to request OTP';
      if (e is AuthException || e is HttpException) {
        msg = e.toString();
      } else {
        msg = e.toString();
      }

      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  /// Step 2: Verify OTP code and get verification token
  FutureOr<void> _onVerifyOTP(AuthVerifyOTP event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final verificationToken = await api.verifyOtp(event.email, event.otp);

      emit(
        state.copyWith(
          status: AuthStatus.success,
          message: 'OTP verified successfully',
          verificationToken: verificationToken,
        ),
      );
    } catch (e) {
      String msg = 'OTP verification failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  /// Step 3: Create password (optional step)
  FutureOr<void> _onCreatePassword(AuthCreatePassword event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final ok = await api.createPassword(event.password);

      if (ok) {
        emit(state.copyWith(status: AuthStatus.success, message: 'Password created successfully'));

        // Automatically fetch registration options after password creation
        add(AuthFetchRegistrationOptions());
      } else {
        emit(state.copyWith(status: AuthStatus.failure, message: 'Failed to create password'));
      }
    } catch (e) {
      String msg = 'Create password failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  /// Step 4: Fetch registration options (gender & nationality)
  FutureOr<void> _onFetchRegistrationOptions(AuthFetchRegistrationOptions event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final options = await api.fetchRegistrationOptions();
      await cache.saveRegistrationOptions(options.toJson());

      emit(state.copyWith(status: AuthStatus.success, message: 'Registration options loaded'));
    } catch (e) {
      String msg = 'Failed to fetch registration options';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  /// Step 5: Submit personal details (final registration step)
  FutureOr<void> _onSubmitPersonalDetails(AuthSubmitPersonalDetails event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final responseData = await api.submitPersonalDetails(
        verificationToken: event.verificationToken,
        fullname: event.fullname,
        dateOfBirth: event.dateOfBirth,
        genderId: event.genderId,
        nationalityId: event.nationalityId,
        kycType: event.kycType,
        kycData: event.kycData,
      );

      // Extract and save token
      final token = Token(
        accessToken: responseData['accessToken'] ?? responseData['access_token'] ?? '',
        refreshToken: responseData['refreshToken'] ?? responseData['refresh_token'],
        tokenType: 'Bearer',
      );

      await cache.saveToken(token);

      // Save user data
      await cache.saveUser({
        'email': responseData['email'] ?? '',
        'username': responseData['username'] ?? event.fullname,
        'currentBalance': responseData['currentBalance'] ?? 0,
      });

      emit(state.copyWith(status: AuthStatus.success, message: 'Registration completed successfully'));
    } catch (e) {
      String msg = 'Registration failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }

  /// Login with credentials
  FutureOr<void> _onLoginWithCredentials(AuthLoginWithCredentials event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final token = await api.login(event.email, event.password);
      await cache.saveToken(token);

      emit(state.copyWith(status: AuthStatus.success, message: 'Login successful'));
    } catch (e) {
      String msg = 'Login failed';
      if (e is AuthException || e is HttpException) msg = e.toString();
      emit(state.copyWith(status: AuthStatus.failure, message: msg));
    }
  }
}
