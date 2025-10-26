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
