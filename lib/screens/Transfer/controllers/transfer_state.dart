import 'package:equatable/equatable.dart';
import '../models/transfer_models.dart';

enum TransferStatus {
  initial,
  loading,
  loaded,
  error,
  validating,
  validated,
  verifyingPin,
  pinVerified,
  confirming,
  confirmed,
}

class TransferState extends Equatable {
  final TransferStatus status;
  final List<FromAccount> fromAccounts;
  final FromAccount? selectedFromAccount;
  final TransferRecipient? recipient;
  final String? errorMessage;
  final Map<String, dynamic>? validationData; // Contains fromAccountDetails and toAccountDetails from /validate
  final int? transactionAmount;
  final String? transactionNote;
  final Map<String, dynamic>? confirmationData; // Contains response from /transfer/confirm

  const TransferState({
    this.status = TransferStatus.initial,
    this.fromAccounts = const [],
    this.selectedFromAccount,
    this.recipient,
    this.errorMessage,
    this.validationData,
    this.transactionAmount,
    this.transactionNote,
    this.confirmationData,
  });

  TransferState copyWith({
    TransferStatus? status,
    List<FromAccount>? fromAccounts,
    FromAccount? Function()? selectedFromAccount,
    TransferRecipient? Function()? recipient,
    String? Function()? errorMessage,
    Map<String, dynamic>? Function()? validationData,
    int? transactionAmount,
    String? transactionNote,
    Map<String, dynamic>? Function()? confirmationData,
  }) {
    return TransferState(
      status: status ?? this.status,
      fromAccounts: fromAccounts ?? this.fromAccounts,
      selectedFromAccount: selectedFromAccount != null ? selectedFromAccount() : this.selectedFromAccount,
      recipient: recipient != null ? recipient() : this.recipient,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      validationData: validationData != null ? validationData() : this.validationData,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      transactionNote: transactionNote ?? this.transactionNote,
      confirmationData: confirmationData != null ? confirmationData() : this.confirmationData,
    );
  }

  bool get isLoading => status == TransferStatus.loading;
  bool get isLoaded => status == TransferStatus.loaded;
  bool get hasError => status == TransferStatus.error;
  bool get hasFromAccounts => fromAccounts.isNotEmpty;
  bool get hasRecipient => recipient != null;
  bool get isValidating => status == TransferStatus.validating;
  bool get isValidated => status == TransferStatus.validated;
  bool get isVerifyingPin => status == TransferStatus.verifyingPin;
  bool get isPinVerified => status == TransferStatus.pinVerified;
  bool get isConfirming => status == TransferStatus.confirming;
  bool get isConfirmed => status == TransferStatus.confirmed;

  @override
  List<Object?> get props => [
    status,
    fromAccounts,
    selectedFromAccount,
    recipient,
    errorMessage,
    validationData,
    transactionAmount,
    transactionNote,
    confirmationData,
  ];
}
