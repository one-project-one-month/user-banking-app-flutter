import 'package:equatable/equatable.dart';
import '../models/transaction.dart';
import 'transaction_event.dart';

enum TransactionStatus { initial, loading, loaded, refreshing, error }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<RecentTransfer> allTransactions;
  final List<RecentTransfer> filteredTransactions;
  final String? errorMessage;
  final TransactionFilterType activeFilter;
  final DateFilterType activeDateFilter;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.allTransactions = const [],
    this.filteredTransactions = const [],
    this.errorMessage,
    this.activeFilter = TransactionFilterType.all,
    this.activeDateFilter = DateFilterType.all,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<RecentTransfer>? allTransactions,
    List<RecentTransfer>? filteredTransactions,
    String? errorMessage,
    TransactionFilterType? activeFilter,
    DateFilterType? activeDateFilter,
  }) {
    return TransactionState(
      status: status ?? this.status,
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      errorMessage: errorMessage,
      activeFilter: activeFilter ?? this.activeFilter,
      activeDateFilter: activeDateFilter ?? this.activeDateFilter,
    );
  }

  bool get isLoading => status == TransactionStatus.loading;
  bool get isLoaded => status == TransactionStatus.loaded;
  bool get isRefreshing => status == TransactionStatus.refreshing;
  bool get hasError => status == TransactionStatus.error;
  bool get hasData => allTransactions.isNotEmpty;

  // Get recent transactions (limit to 3 for home screen)
  List<RecentTransfer> get recentTransactions {
    return filteredTransactions.take(3).toList();
  }

  // Group transactions by date
  Map<String, List<RecentTransfer>> get groupedByDate {
    final Map<String, List<RecentTransfer>> grouped = {};

    for (final transaction in filteredTransactions) {
      // You can implement proper date grouping here
      // For now, using a placeholder date
      final date = '25/09/2025'; // This should come from actual transaction data

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    return grouped;
  }

  @override
  List<Object?> get props => [
    status,
    allTransactions,
    filteredTransactions,
    errorMessage,
    activeFilter,
    activeDateFilter,
  ];
}
