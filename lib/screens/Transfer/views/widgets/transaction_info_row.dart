import 'package:flutter/material.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';

class TransactionInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final double? labelFontSize;
  final double? valueFontSize;
  final FontWeight? labelFontWeight;
  final FontWeight? valueFontWeight;

  const TransactionInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.labelFontSize,
    this.valueFontSize,
    this.labelFontWeight,
    this.valueFontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: CommonSize.s8(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor ?? const Color(0xFF002D62),
              fontSize: labelFontSize ?? CommonSize.s14(context),
              fontWeight: labelFontWeight ?? FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? const Color(0xFF002D62),
              fontSize: valueFontSize ?? CommonSize.s14(context),
              fontWeight: valueFontWeight ?? FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
