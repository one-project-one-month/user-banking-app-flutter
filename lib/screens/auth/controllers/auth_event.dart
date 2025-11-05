import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitialEvent extends AuthEvent {}

// For submitting personal details (final registration step)
class AuthSubmitPersonalDetails extends AuthEvent {
  final String verificationToken;
  final String fullname;
  final String dateOfBirth; // format: "2025-11-03"
  final int genderId;
  final int nationalityId;
  final String kycType;
  final String kycData;

  const AuthSubmitPersonalDetails({
    required this.verificationToken,
    required this.fullname,
    required this.dateOfBirth,
    required this.genderId,
    required this.nationalityId,
    required this.kycType,
    required this.kycData,
  });

  @override
  List<Object?> get props => [verificationToken, fullname, dateOfBirth, genderId, nationalityId, kycType, kycData];
}

class AuthLoginWithGoogle extends AuthEvent {}

// Login with username and password
class AuthLoginWithCredentials extends AuthEvent {
  final String username;
  final String password;
  const AuthLoginWithCredentials(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

// Request OTP to be sent to email
class AuthRequestOTP extends AuthEvent {
  final String email;
  const AuthRequestOTP(this.email);

  @override
  List<Object?> get props => [email];
}

// Verify OTP code
class AuthVerifyOTP extends AuthEvent {
  final String email;
  final String otp;
  const AuthVerifyOTP(this.email, this.otp);

  @override
  List<Object?> get props => [email, otp];
}

class AuthCreatePassword extends AuthEvent {
  final String password;
  const AuthCreatePassword(this.password);

  @override
  List<Object?> get props => [password];
}

// Fetch gender and nationality options
class AuthFetchRegistrationOptions extends AuthEvent {}
