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
    on<TransactionLoadData>(_onLoadData);
    on<TransactionRefreshData>(_onRefreshData);
    on<TransactionFilterByType>(_onFilterByType);
    on<TransactionFilterByDateRange>(_onFilterByDateRange);
  }

  FutureOr<void> _onLoadData(TransactionLoadData event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    try {
      // Get token from cache
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(
          state.copyWith(status: TransactionStatus.error, errorMessage: 'No authentication token found. Please login.'),
        );
        return;
      }

      // Check if token is expired
      if (token.isExpired) {
        emit(state.copyWith(status: TransactionStatus.error, errorMessage: 'Session expired. Please login again.'));
        return;
      }

      // Fetch recent transfers from API
      final transfers = await api.getRecentTransfers(token.accessToken);

      print('✅ Loaded ${transfers.length} transactions');

      emit(
        state.copyWith(
          status: TransactionStatus.loaded,
          allTransactions: transfers,
          filteredTransactions: transfers,
          errorMessage: null,
        ),
      );
    } catch (e) {
      String errorMsg = 'Failed to load transactions';
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

      final transfers = await api.getRecentTransfers(token.accessToken);

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

    // Apply date filter (implement based on your date logic)
    // For now, this is a placeholder
    switch (dateFilter) {
      case DateFilterType.yesterday:
        // Filter for yesterday's transactions
        break;
      case DateFilterType.lastWeek:
        // Filter for last week's transactions
        break;
      case DateFilterType.lastMonth:
        // Filter for last month's transactions
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
