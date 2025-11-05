import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'transfer_event.dart';
import 'transfer_state.dart';
import '../services/transfer_api_service.dart';
import '../../auth/services/cache_service.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferApiService api;
  final CacheService cache;

  TransferBloc({
    TransferApiService? apiService,
    CacheService? cacheService,
  })  : api = apiService ?? TransferApiService(baseUrl: "http://10.0.2.2:7777"),
        cache = cacheService ?? CacheService(),
        super(const TransferState()) {
    on<TransferLoadFromAccounts>(_onLoadFromAccounts);
    on<TransferPrepareByNickname>(_onPrepareByNickname);
    on<TransferPrepareByAccountNumber>(_onPrepareByAccountNumber);
    on<TransferClearRecipient>(_onClearRecipient);
  }

  /// Load from accounts
  FutureOr<void> _onLoadFromAccounts(
    TransferLoadFromAccounts event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.loading));

    try {
      // Get token from cache
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

      // Check if token is expired
      if (token.isExpired) {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => 'Session expired. Please login again.',
          ),
        );
        return;
      }

      // Fetch from accounts
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

      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: () => errorMsg,
        ),
      );
    }
  }

  /// Prepare transfer by nickname
  FutureOr<void> _onPrepareByNickname(
    TransferPrepareByNickname event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => 'No authentication token found',
          ),
        );
        return;
      }

      // Get recipient details
      final recipient = await api.prepareTransferByNickname(
        token.accessToken,
        event.nicknameId,
      );

      emit(
        state.copyWith(
          status: TransferStatus.loaded,
          recipient: () => recipient,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to get recipient details';
      if (e is TransferApiException) {
        errorMsg = e.message;
      }

      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: () => errorMsg,
        ),
      );
    }
  }

  /// Prepare transfer by raw toAccountNumber
  FutureOr<void> _onPrepareByAccountNumber(
    TransferPrepareByAccountNumber event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(
            status: TransferStatus.error,
            errorMessage: () => 'No authentication token found',
          ),
        );
        return;
      }

      final recipient = await api.prepareTransferByAccountNumber(
        token.accessToken,
        event.toAccountNumber,
      );

      emit(
        state.copyWith(
          status: TransferStatus.loaded,
          recipient: () => recipient,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to verify account number';
      if (e is TransferApiException) {
        errorMsg = e.message;
      }

      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: () => errorMsg,
        ),
      );
    }
  }

  /// Clear recipient
  FutureOr<void> _onClearRecipient(
    TransferClearRecipient event,
    Emitter<TransferState> emit,
  ) async {
    emit(
      state.copyWith(
        recipient: () => null,
        errorMessage: () => null,
      ),
    );
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}