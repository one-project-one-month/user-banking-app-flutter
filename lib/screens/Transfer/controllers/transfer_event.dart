import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

/// Load from accounts (user's accounts)
class TransferLoadFromAccounts extends TransferEvent {
  const TransferLoadFromAccounts();
}

/// Prepare transfer by nickname
class TransferPrepareByNickname extends TransferEvent {
  final String nicknameId;
  
  const TransferPrepareByNickname(this.nicknameId);
  
  @override
  List<Object?> get props => [nicknameId];
}

/// Prepare transfer by entering destination account number
class TransferPrepareByAccountNumber extends TransferEvent {
  final String toAccountNumber;

  const TransferPrepareByAccountNumber(this.toAccountNumber);

  @override
  List<Object?> get props => [toAccountNumber];
}

/// Clear recipient (when user changes selection)
class TransferClearRecipient extends TransferEvent {
  const TransferClearRecipient();
}