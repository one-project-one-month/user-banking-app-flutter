import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? message;
  final String? verificationToken; // Store token from OTP verification
  final String? otpCode; // Store OTP for display (from email/verify response)

  const AuthState({this.status = AuthStatus.initial, this.message, this.verificationToken, this.otpCode});

  AuthState copyWith({AuthStatus? status, String? message, String? verificationToken, String? otpCode}) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      verificationToken: verificationToken ?? this.verificationToken,
      otpCode: otpCode ?? this.otpCode,
    );
  }

  @override
  List<Object?> get props => [status, message, verificationToken, otpCode];
}
