import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitialEvent extends AuthEvent {}

class AuthRegisterSubmitted extends AuthEvent {
  final Map<String, dynamic> payload;
  const AuthRegisterSubmitted(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AuthLoginWithGoogle extends AuthEvent {}

class AuthLoginWithCredentials extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginWithCredentials(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthRequestOTP extends AuthEvent {
  final String payload; // destination (phone or email)
  const AuthRequestOTP(this.payload);

  @override
  List<Object?> get props => [payload];
}

class AuthConfirmOTP extends AuthEvent {
  final String destination;
  final String code;
  const AuthConfirmOTP(this.destination, this.code);

  @override
  List<Object?> get props => [destination, code];
}

class AuthCreatePassword extends AuthEvent {
  //  final String destination;
  // final String code;
  final String password;
  const AuthCreatePassword(
    //this.destination, this.code,
    this.password,
  );

  @override
  List<Object?> get props => [
    //destination, code,
    password,
  ];
}

class AuthFetchRegistrationOptions extends AuthEvent {}
