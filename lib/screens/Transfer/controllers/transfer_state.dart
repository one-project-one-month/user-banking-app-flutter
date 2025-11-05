import 'package:equatable/equatable.dart';
import '../models/transfer_models.dart';

enum TransferStatus { initial, loading, loaded, error }

class TransferState extends Equatable {
  final TransferStatus status;
  final List<FromAccount> fromAccounts;
  final FromAccount? selectedFromAccount;
  final TransferRecipient? recipient;
  final String? errorMessage;

  const TransferState({
    this.status = TransferStatus.initial,
    this.fromAccounts = const [],
    this.selectedFromAccount,
    this.recipient,
    this.errorMessage,
  });

  TransferState copyWith({
    TransferStatus? status,
    List<FromAccount>? fromAccounts,
    FromAccount? Function()? selectedFromAccount,
    TransferRecipient? Function()? recipient,
    String? Function()? errorMessage,
  }) {
    return TransferState(
      status: status ?? this.status,
      fromAccounts: fromAccounts ?? this.fromAccounts,
      selectedFromAccount: selectedFromAccount != null 
          ? selectedFromAccount() 
          : this.selectedFromAccount,
      recipient: recipient != null ? recipient() : this.recipient,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  bool get isLoading => status == TransferStatus.loading;
  bool get isLoaded => status == TransferStatus.loaded;
  bool get hasError => status == TransferStatus.error;
  bool get hasFromAccounts => fromAccounts.isNotEmpty;
  bool get hasRecipient => recipient != null;

  @override
  List<Object?> get props => [
        status,
        fromAccounts,
        selectedFromAccount,
        recipient,
        errorMessage,
      ];
}