import 'package:equatable/equatable.dart';
import '../models/user.dart';

enum UserStatus { initial, loading, loaded, refreshing, error }

class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final String? errorMessage;

  const UserState({this.status = UserStatus.initial, this.user, this.errorMessage});

  UserState copyWith({UserStatus? status, User? Function()? user, String? errorMessage}) {
    return UserState(
      status: status ?? this.status,
      user: user != null ? user() : this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper method for setting user without nullable wrapper
  UserState copyWithUser({UserStatus? status, User? user, String? errorMessage}) {
    return UserState(status: status ?? this.status, user: user ?? this.user, errorMessage: errorMessage);
  }

  bool get isLoading => status == UserStatus.loading;
  bool get isLoaded => status == UserStatus.loaded;
  bool get isRefreshing => status == UserStatus.refreshing;
  bool get hasError => status == UserStatus.error;
  bool get hasData => user != null;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
