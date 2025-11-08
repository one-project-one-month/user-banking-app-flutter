import 'package:banking_app/core/utils/main_screen/transaction_card.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_bloc.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_event.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({super.key});

  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
  @override
  void initState() {
    super.initState();
    // Load transactions when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionBloc>().add(const TransactionLoadData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Transactions History',
          style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'DMsansSB'),
        ),
        backgroundColor: Color(0xff072B46),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionBloc>().add(const TransactionRefreshData());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Transactions',
                        style: TextStyle(color: Color(0xff032c46), fontSize: 18, fontFamily: 'DMsansSB'),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // TODO: Show filter dialog
                            },
                            icon: Icon(Icons.filter_list_alt),
                            padding: EdgeInsets.zero,
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Show date picker
                            },
                            icon: Icon(Icons.date_range),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      FilterCard(
                        label: 'Yesterday',
                        isActive: state.activeDateFilter == DateFilterType.yesterday,
                        onTap: () {
                          context.read<TransactionBloc>().add(
                            const TransactionFilterByDateRange(DateFilterType.yesterday),
                          );
                        },
                      ),
                      FilterCard(
                        label: 'Last Week',
                        isActive: state.activeDateFilter == DateFilterType.lastWeek,
                        onTap: () {
                          context.read<TransactionBloc>().add(
                            const TransactionFilterByDateRange(DateFilterType.lastWeek),
                          );
                        },
                      ),
                      FilterCard(
                        label: 'Last Month',
                        isActive: state.activeDateFilter == DateFilterType.lastMonth,
                        onTap: () {
                          context.read<TransactionBloc>().add(
                            const TransactionFilterByDateRange(DateFilterType.lastMonth),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.5),
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  color: Color(0xfff2f4f6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilterCard(
                        label: 'All',
                        isActive: state.activeFilter == TransactionFilterType.all,
                        onTap: () {
                          context.read<TransactionBloc>().add(const TransactionFilterByType(TransactionFilterType.all));
                        },
                        isBlue: true,
                      ),
                      FilterCard(
                        label: 'InFlow',
                        isActive: state.activeFilter == TransactionFilterType.inflow,
                        onTap: () {
                          context.read<TransactionBloc>().add(
                            const TransactionFilterByType(TransactionFilterType.inflow),
                          );
                        },
                        isBlue: true,
                      ),
                      FilterCard(
                        label: 'OutFlow',
                        isActive: state.activeFilter == TransactionFilterType.outflow,
                        onTap: () {
                          context.read<TransactionBloc>().add(
                            const TransactionFilterByType(TransactionFilterType.outflow),
                          );
                        },
                        isBlue: true,
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildTransactionList(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionList(TransactionState state) {
    if (state.isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError && !state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Failed to load transactions',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TransactionBloc>().add(const TransactionLoadData());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!state.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No transactions found', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = state.groupedByDate;
    final dates = groupedTransactions.keys.toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final date = dates[index];
        final transactions = groupedTransactions[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Color(0xff062c46),
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Text(date, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            ...transactions.map((transaction) {
              return TransactionCard(
                name: transaction.user.name,
                amount: transaction.account.balance.toStringAsFixed(0),
                income: transaction.isIncome,
                time: transaction.time ?? '',
                walltetNumber: transaction.account.accountNumber,
                quickPay: transaction.quickPay,
              );
            }).toList(),
          ],
        );
      },
      itemCount: dates.length,
    );
  }
}

// ignore: must_be_immutable
class FilterCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isBlue;
  final bool isActive;

  FilterCard({super.key, required this.label, required this.onTap, this.isBlue = false, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color:
            isActive
                ? (isBlue ? Color(0xff072B46) : Color(0xff1888D9))
                : (isBlue ? Color(0xff072B46).withOpacity(0.7) : Colors.white),
        elevation: isActive ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: isActive ? BorderSide(color: Color(0xff1888D9), width: 2) : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : (isBlue ? Colors.white70 : Color(0xff1E2939)),
              fontSize: 16,
              fontFamily: isActive ? 'DMsansSB' : 'DMsansR',
            ),
          ),
        ),
      ),
    );
  }
}
