import 'package:flutter/material.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'pin_dot.dart';

class PinInputDisplay extends StatelessWidget {
  final String pin;
  final int maxLength;

  const PinInputDisplay({super.key, required this.pin, this.maxLength = 6});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < pin.length;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: CommonSize.s8(context)),
          child: PinDot(isFilled: isFilled, size: CommonSize.s14(context)),
        );
      }),
    );
  }
}
