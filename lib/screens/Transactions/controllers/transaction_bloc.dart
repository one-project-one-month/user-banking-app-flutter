import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'transaction_event.dart';
import 'transaction_state.dart';
import '../services/transaction_service.dart';
import '../../auth/services/cache_service.dart';
import '../models/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService api;
  final CacheService cache;

  TransactionBloc({TransactionService? apiService, CacheService? cacheService})
    : api = apiService ?? TransactionService(baseUrl: "http://10.0.2.2:7777"),
      cache = cacheService ?? CacheService(),
      super(const TransactionState()) {
    // Register all event handlers
    on<TransactionLoadRecentTransfers>(_onLoadRecentTransfers);
    on<TransactionLoadHistory>(_onLoadHistory);
    on<TransactionRefreshData>(_onRefreshData);
    on<TransactionFilterByType>(_onFilterByType);
    on<TransactionFilterByDateRange>(_onFilterByDateRange);
  }

  /// Load recent transfers (for home screen - 5 most recent)
  FutureOr<void> _onLoadRecentTransfers(TransactionLoadRecentTransfers event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(status: TransactionStatus.error, errorMessage: 'No authentication token found. Please login.'),
        );
        return;
      }

      if (token.isExpired) {
        emit(state.copyWith(status: TransactionStatus.error, errorMessage: 'Session expired. Please login again.'));
        return;
      }

      final transfers = await api.getRecentTransfers(token.accessToken);

      print('✅ Loaded ${transfers.length} recent transfers for home screen');

      emit(
        state.copyWith(
          status: TransactionStatus.loaded,
          allTransactions: transfers,
          filteredTransactions: transfers,
          errorMessage: null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to load recent transfers';
      if (e is TransactionServiceException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      print('❌ TransactionBloc error: $errorMsg');
      emit(state.copyWith(status: TransactionStatus.error, errorMessage: errorMsg));
    }
  }

  /// Load transaction history (for transaction history screen - all transactions)
  FutureOr<void> _onLoadHistory(TransactionLoadHistory event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(status: TransactionStatus.error, errorMessage: 'No authentication token found. Please login.'),
        );
        return;
      }

      if (token.isExpired) {
        emit(state.copyWith(status: TransactionStatus.error, errorMessage: 'Session expired. Please login again.'));
        return;
      }

      final transfers = await api.getTransactionHistory(token.accessToken);

      print('✅ Loaded ${transfers.length} transactions for history screen');

      emit(
        state.copyWith(
          status: TransactionStatus.loaded,
          allTransactions: transfers,
          filteredTransactions: transfers,
          errorMessage: null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to load transaction history';
      if (e is TransactionServiceException) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString();
      }

      print('❌ TransactionBloc error: $errorMsg');
      emit(state.copyWith(status: TransactionStatus.error, errorMessage: errorMsg));
    }
  }

  /// Refresh transaction data (pull to refresh)
  FutureOr<void> _onRefreshData(TransactionRefreshData event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.refreshing));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: TransactionStatus.error, errorMessage: 'No authentication token found'));
        return;
      }

      // Load appropriate data based on context
      // If we have fewer than 10 transactions, it's likely the home screen (recent)
      // Otherwise, it's the history screen (all)
      final transfers =
          state.allTransactions.length <= 10
              ? await api.getRecentTransfers(token.accessToken)
              : await api.getTransactionHistory(token.accessToken);

      // Apply current filters
      final filtered = _applyFilters(transfers, state.activeFilter, state.activeDateFilter);

      emit(
        state.copyWith(
          status: TransactionStatus.loaded,
          allTransactions: transfers,
          filteredTransactions: filtered,
          errorMessage: null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to refresh transactions';
      if (e is TransactionServiceException) {
        errorMsg = e.message;
      }

      emit(state.copyWith(status: TransactionStatus.error, errorMessage: errorMsg));
    }
  }

  /// Filter transactions by type (all, inflow, outflow)
  FutureOr<void> _onFilterByType(TransactionFilterByType event, Emitter<TransactionState> emit) async {
    final filtered = _applyFilters(state.allTransactions, event.filterType, state.activeDateFilter);

    emit(state.copyWith(filteredTransactions: filtered, activeFilter: event.filterType));
  }

  /// Filter transactions by date range
  FutureOr<void> _onFilterByDateRange(TransactionFilterByDateRange event, Emitter<TransactionState> emit) async {
    final filtered = _applyFilters(state.allTransactions, state.activeFilter, event.dateFilter);

    emit(state.copyWith(filteredTransactions: filtered, activeDateFilter: event.dateFilter));
  }

  /// Apply both type and date filters
  List<RecentTransfer> _applyFilters(
    List<RecentTransfer> transactions,
    TransactionFilterType typeFilter,
    DateFilterType dateFilter,
  ) {
    var filtered = transactions;

    // Apply type filter
    switch (typeFilter) {
      case TransactionFilterType.inflow:
        filtered = filtered.where((t) => t.isIncome).toList();
        break;
      case TransactionFilterType.outflow:
        filtered = filtered.where((t) => !t.isIncome).toList();
        break;
      case TransactionFilterType.all:
        break;
    }

    // Apply date filter
    final now = DateTime.now();
    switch (dateFilter) {
      case DateFilterType.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        filtered =
            filtered.where((t) {
              // This is a placeholder - you'll need to add proper date parsing
              // based on your actual transaction time format
              return true; // TODO: implement date comparison
            }).toList();
        break;
      case DateFilterType.lastWeek:
        final lastWeek = now.subtract(const Duration(days: 7));
        filtered =
            filtered.where((t) {
              // TODO: implement date comparison
              return true;
            }).toList();
        break;
      case DateFilterType.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        filtered =
            filtered.where((t) {
              // TODO: implement date comparison
              return true;
            }).toList();
        break;
      case DateFilterType.all:
        break;
    }

    return filtered;
  }

  @override
  Future<void> close() {
    api.dispose();
    return super.close();
  }
}
