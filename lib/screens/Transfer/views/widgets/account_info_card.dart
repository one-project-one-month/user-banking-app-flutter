import 'package:flutter/material.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';

class AccountInfoCard extends StatelessWidget {
  final String name;
  final String accountNumber;
  final String? amount;
  final Color? amountColor;

  const AccountInfoCard({
    super.key,
    required this.name,
    required this.accountNumber,
    this.amount,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(CommonSize.s12(context)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(CommonSize.s8(context)),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: CommonSize.s40(context),
            height: CommonSize.s40(context),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Center(
              child: Text(
                'Logo',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: CommonSize.s10(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          SizedBox(width: CommonSize.s12(context)),

          // Account details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF002D62),
                    fontSize: CommonSize.s16(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: CommonSize.s4(context)),
                Text(
                  accountNumber,
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: CommonSize.s12(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (amount != null) ...[
                  SizedBox(height: CommonSize.s6(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CommonSize.s8(context),
                      vertical: CommonSize.s4(context),
                    ),
                    decoration: BoxDecoration(
                      color: (amountColor ?? const Color(0xFFFFA726))
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        CommonSize.s4(context),
                      ),
                    ),
                    child: Text(
                      amount!,
                      style: TextStyle(
                        color: amountColor ?? const Color(0xFFFFA726),
                        fontSize: CommonSize.s14(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
