import 'package:equatable/equatable.dart';

abstract class NicknameEvent extends Equatable {
  const NicknameEvent();

  @override
  List<Object?> get props => [];
}

class NicknameChanged extends NicknameEvent {
  final String nickname;
  final String accountNumber;

  const NicknameChanged(this.nickname, this.accountNumber);

  @override
  List<Object?> get props => [nickname, accountNumber];
}
