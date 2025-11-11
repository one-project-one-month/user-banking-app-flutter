import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Load recent transfers from API (for home screen - 5 most recent)
class TransactionLoadRecentTransfers extends TransactionEvent {
  const TransactionLoadRecentTransfers();
}

/// Load full transaction history from API (for transaction history screen - all)
class TransactionLoadHistory extends TransactionEvent {
  const TransactionLoadHistory();
}

/// Refresh recent transfers (pull to refresh)
class TransactionRefreshData extends TransactionEvent {
  const TransactionRefreshData();
}

/// Filter transactions by type (all, inflow, outflow)
class TransactionFilterByType extends TransactionEvent {
  final TransactionFilterType filterType;

  const TransactionFilterByType(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

/// Filter transactions by date range
class TransactionFilterByDateRange extends TransactionEvent {
  final DateFilterType dateFilter;

  const TransactionFilterByDateRange(this.dateFilter);

  @override
  List<Object?> get props => [dateFilter];
}

enum TransactionFilterType { all, inflow, outflow }

enum DateFilterType { all, yesterday, lastWeek, lastMonth }
