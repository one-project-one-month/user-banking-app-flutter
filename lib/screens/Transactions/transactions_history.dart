import 'package:banking_app/core/utils/main_screen/transaction_card.dart';
import 'package:flutter/material.dart';

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({super.key});

  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
  @override
  Widget build(BuildContext context) {
    List<String> dates = ['25/09/2025', '24/09/2025'];
    Map<String, dynamic> transactions = {
      '25/09/2025': [
        TransactionModel(
          name: 'John Doe',
          amount: '500000',
          income: true,
          time: '10:30 AM',
          walltetNumber: '1234 5678 9012',
          quickPay: false,
        ),
        TransactionModel(
          name: 'Jane Smith',
          amount: '500000',
          income: false,
          time: '2:15 PM',
          walltetNumber: '9876 5432 1098',
          quickPay: false,
        ),
        TransactionModel(
          name: 'Jane Smith',
          amount: '500000',
          income: false,
          time: '2:15 PM',
          walltetNumber: '9876 5432 1098',
          quickPay: false,
        ),
      ],
      '24/09/2025': [
        TransactionModel(
          name: 'Alice Johnson',
          amount: '500000',
          income: true,
          time: '11:00 AM',
          walltetNumber: '4567 8901 2345',
          quickPay: true,
        ),
        TransactionModel(
          name: 'Bob Brown',
          amount: '500000',
          income: false,
          time: '4:45 PM',
          walltetNumber: '6543 2109 8765',
          quickPay: true,
        ),
        TransactionModel(
          name: 'Bob Brown',
          amount: '500000',
          income: false,
          time: '4:45 PM',
          walltetNumber: '6543 2109 8765',
          quickPay: true,
        ),
      ],
    };
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Transactions History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'DMsansSB',
          ),
        ),
        backgroundColor: Color(0xff072B46),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Transactions',
                    style: TextStyle(
                      color: Color(0xff032c46),
                      fontSize: 18,
                      fontFamily: 'DMsansSB',
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.filter_list_alt),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        onPressed: () {},
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
                  FilterCard(label: 'Yesterday', onTap: () {}),
                  FilterCard(label: 'Last Week', onTap: () {}),
                  FilterCard(label: 'Last Month', onTap: () {}),
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
                  FilterCard(label: 'All', onTap: () {}, isBlue: true),
                  FilterCard(label: 'InFlow', onTap: () {}, isBlue: true),
                  FilterCard(label: 'OutFlow', onTap: () {}, isBlue: true),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  String date = dates[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Color(0xff062c46),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10,
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ...transactions[date].map((transaction) {
                        return TransactionCard(
                          name: transaction.name,
                          amount: transaction.amount,
                          income: transaction.income,
                          time: transaction.time,
                          walltetNumber: transaction.walltetNumber,
                          quickPay: transaction.quickPay,
                        );
                      }).toList(),
                    ],
                  );
                },
                itemCount: dates.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FilterCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  bool isBlue;
  FilterCard({
    super.key,
    required this.label,
    required this.onTap,
    this.isBlue = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isBlue ? Color(0xff072B46) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            label,
            style: TextStyle(
              color: isBlue ? Colors.white : Color(0xff1E2939),
              fontSize: 16,
              fontFamily: 'DMsansR',
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionModel {
  final String name;
  final String amount;
  final bool income;
  final String time;
  final String walltetNumber;
  final bool quickPay;
  TransactionModel({
    required this.name,
    required this.amount,
    required this.income,
    required this.time,
    required this.walltetNumber,
    required this.quickPay,
  });
}
