import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String name;
  final String amount;
  final bool income;
  final String time;
  final String walltetNumber;
  final bool quickPay;

  const TransactionCard({
    super.key,
    required this.name,
    required this.amount,
    required this.income,
    required this.time,
    required this.walltetNumber,
    required this.quickPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xff486d89), width: 1),
        ),
      ),
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                quickPay
                    ? 'Quick Pay'
                    : income
                    ? 'Transfer From $name'
                    : 'Transfer To $name',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'DMsansSB',
                  color: Color(0xff000000),
                ),
              ),
              Text(
                'E-Wallet No: $walltetNumber',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontFamily: 'DMsansR',
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0A3D62),
                ),
              ),
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'DMsansSB',
                  color: Colors.black,
                ),
              ),
              Text(
                income ? '+$amount MMK' : '-$amount MMK',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'DMsansSB',
                  color: income ? Color(0xff0A3D62) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
