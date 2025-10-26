import 'package:equatable/equatable.dart';

class NicknameState extends Equatable {
  final String nickname;
  final String accountNumber;
  final bool isButtonEnabled;

  const NicknameState({
    this.nickname = '',
    this.accountNumber = '',
    this.isButtonEnabled = false,
  });

  NicknameState copyWith({
    String? nickname,
    String? accountNumber,
    bool? isButtonEnabled,
  }) {
    return NicknameState(
      nickname: nickname ?? this.nickname,
      accountNumber: accountNumber ?? this.accountNumber,
      isButtonEnabled: isButtonEnabled ?? this.isButtonEnabled,
    );
  }

  @override
  List<Object?> get props => [nickname, accountNumber, isButtonEnabled];
}
