import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Load user data from API
class UserLoadData extends UserEvent {
  const UserLoadData();
}

/// Refresh user data (pull to refresh)
class UserRefreshData extends UserEvent {
  const UserRefreshData();
}

/// Update balance locally (after transaction)
class UserUpdateBalance extends UserEvent {
  final double newBalance;

  const UserUpdateBalance(this.newBalance);

  @override
  List<Object?> get props => [newBalance];
}

/// Clear user data (logout)
class UserClearData extends UserEvent {
  const UserClearData();
}
