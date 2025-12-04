import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'transfer_event.dart';
import 'transfer_state.dart';
import '../services/transfer_api_service.dart';
import '../../auth/services/cache_service.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferApiService api;
  final CacheService cache;

  TransferBloc({TransferApiService? apiService, CacheService? cacheService})
    : api = apiService ?? TransferApiService(baseUrl: "https://136.112.160.13:7777"),
      cache = cacheService ?? CacheService(),
      super(const TransferState()) {
    on<TransferLoadFromAccounts>(_onLoadFromAccounts);
    on<TransferPrepareByNickname>(_onPrepareByNickname);
    on<TransferPrepareByAccountNumber>(_onPrepareByAccountNumber);
    on<TransferClearRecipient>(_onClearRecipient);
    on<TransferValidateTransaction>(_onValidateTransaction);
    on<TransferStoreTransactionData>(_onStoreTransactionData);
    on<TransferVerifyPin>(_onVerifyPin);
    on<TransferConfirm>(_onConfirm);
  }

  /// Load from accounts
  FutureOr<void> _onLoadFromAccounts(TransferLoadFromAccounts event, Emitter<TransferState> emit) async {
    emit(state.copyWith(status: TransferStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => 'No authentication token found. Please login.',
          ),
        );
        return;
      }

      if (token.isExpired) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: () => 'Session expired. Please login again.'));
        return;
      }

      final accounts = await api.getFromAccounts(token.accessToken);

      emit(
        state.copyWith(
          status: TransferStatus.loaded,
          fromAccounts: accounts,
          selectedFromAccount: () => accounts.isNotEmpty ? accounts.first : null,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to load accounts';
      if (e is TransferApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      print('❌ TransferBloc error: $errorMsg');

      emit(state.copyWith(status: TransferStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Prepare transfer by nickname
  FutureOr<void> _onPrepareByNickname(TransferPrepareByNickname event, Emitter<TransferState> emit) async {
    emit(state.copyWith(status: TransferStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final recipient = await api.prepareTransferByNickname(token.accessToken, event.nicknameId);

      emit(state.copyWith(status: TransferStatus.loaded, recipient: () => recipient, errorMessage: () => null));
    } catch (e) {
      String errorMsg = 'Failed to get recipient details';
      if (e is TransferApiException) {
        errorMsg = e.message;
      }

      emit(state.copyWith(status: TransferStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Prepare transfer by account number
  FutureOr<void> _onPrepareByAccountNumber(TransferPrepareByAccountNumber event, Emitter<TransferState> emit) async {
    emit(state.copyWith(status: TransferStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final recipient = await api.prepareTransferByAccountNumber(token.accessToken, event.toAccountNumber);

      emit(state.copyWith(status: TransferStatus.loaded, recipient: () => recipient, errorMessage: () => null));
    } catch (e) {
      String errorMsg = 'Failed to verify account number';
      if (e is TransferApiException) {
        errorMsg = e.message;
      }

      emit(state.copyWith(status: TransferStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Clear recipient
  FutureOr<void> _onClearRecipient(TransferClearRecipient event, Emitter<TransferState> emit) async {
    emit(state.copyWith(recipient: () => null, errorMessage: () => null));
  }

  /// Validate Transaction (calls /validate endpoint)
  FutureOr<void> _onValidateTransaction(TransferValidateTransaction event, Emitter<TransferState> emit) async {
    emit(state.copyWith(status: TransferStatus.validating));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final result = await api.validateTransfer(token.accessToken, event.toAccountId);

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: TransferStatus.validated,
            validationData: () => result['data'],
            transactionAmount: event.amount,
            transactionNote: event.note,
            errorMessage: () => null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => result['message'] ?? 'Transfer validation failed',
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to validate transfer';
      if (e is TransferApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      emit(state.copyWith(status: TransferStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Store transaction data
  FutureOr<void> _onStoreTransactionData(TransferStoreTransactionData event, Emitter<TransferState> emit) async {
    emit(state.copyWith(transactionAmount: event.amount, transactionNote: event.note));
  }

  /// Verify Transaction PIN
  FutureOr<void> _onVerifyPin(TransferVerifyPin event, Emitter<TransferState> emit) async {
    emit(state.copyWith(status: TransferStatus.verifyingPin));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final result = await api.verifyPin(token.accessToken, event.pin);

      if (result['success'] == true) {
        emit(state.copyWith(status: TransferStatus.pinVerified, errorMessage: () => null));
      } else {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => result['message'] ?? 'PIN verification failed',
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to verify PIN';
      if (e is TransferApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      emit(state.copyWith(status: TransferStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Confirm Transfer (calls /transfer/confirm endpoint)
  FutureOr<void> _onConfirm(TransferConfirm event, Emitter<TransferState> emit) async {
    emit(state.copyWith(status: TransferStatus.confirming));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: TransferStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final result = await api.confirmTransfer(
        token.accessToken,
        event.toAccountId,
        event.amount,
        event.note,
        event.pin,
      );

      if (result['success'] == true) {
        emit(
          state.copyWith(
            status: TransferStatus.confirmed,
            confirmationData: () => result['data'],
            errorMessage: () => null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => result['message'] ?? 'Transfer confirmation failed',
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Failed to confirm transfer';
      if (e is TransferApiException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      emit(state.copyWith(status: TransferStatus.error, errorMessage: () => errorMsg));
    }
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}
