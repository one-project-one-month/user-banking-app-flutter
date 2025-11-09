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

/// Validate Transaction (calls /validate endpoint)
class TransferValidateTransaction extends TransferEvent {
  final int toAccountId;
  final int amount;
  final String note;

  const TransferValidateTransaction({required this.toAccountId, required this.amount, required this.note});

  @override
  List<Object?> get props => [toAccountId, amount, note];
}

/// Store transaction data (amount, note) for use in PIN and success screens
class TransferStoreTransactionData extends TransferEvent {
  final int amount;
  final String note;

  const TransferStoreTransactionData({required this.amount, required this.note});

  @override
  List<Object?> get props => [amount, note];
}

/// Verify Transaction PIN
class TransferVerifyPin extends TransferEvent {
  final String pin;

  const TransferVerifyPin(this.pin);

  @override
  List<Object?> get props => [pin];
}

/// Confirm Transfer (calls /transfer/confirm endpoint after PIN verified)
class TransferConfirm extends TransferEvent {
  final int toAccountId;
  final int amount;
  final String note;
  final String pin;

  const TransferConfirm({required this.toAccountId, required this.amount, required this.note, required this.pin});

  @override
  List<Object?> get props => [toAccountId, amount, note, pin];
}
