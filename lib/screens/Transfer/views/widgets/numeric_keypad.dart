import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback? onBackspace;
  final bool isEnabled;

  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    this.onBackspace,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rows 1-3: Numbers 1-9
        for (int row = 0; row < 3; row++)
          Padding(
            padding: EdgeInsets.symmetric(vertical: CommonSize.s8(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int col = 0; col < 3; col++)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: CommonSize.s8(context),
                    ),
                    child: _KeypadButton(
                      text: '${row * 3 + col + 1}',
                      onPressed: isEnabled
                          ? () => onKeyPressed('${row * 3 + col + 1}')
                          : null,
                    ),
                  ),
              ],
            ),
          ),

        // Row 4: Empty space, 0, Backspace
        Padding(
          padding: EdgeInsets.symmetric(vertical: CommonSize.s8(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty space
              SizedBox(
                width: CommonSize.s64(context) + CommonSize.s16(context),
              ),

              // 0 button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: CommonSize.s8(context),
                ),
                child: _KeypadButton(
                  text: '0',
                  onPressed: isEnabled ? () => onKeyPressed('0') : null,
                ),
              ),

              // Backspace button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: CommonSize.s8(context),
                ),
                child: _KeypadButton(
                  icon: Icons.backspace,
                  onPressed: isEnabled ? onBackspace : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const _KeypadButton({this.text, this.icon, this.onPressed})
    : assert(
        text != null || icon != null,
        'Either text or icon must be provided',
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed != null
          ? () {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          : null,
      child: Container(
        width: CommonSize.s64(context),
        height: CommonSize.s64(context),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onPressed != null
              ? const Color(0xFFB0BEC5)
              : const Color(0xFFB0BEC5).withOpacity(0.3),
        ),
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: CommonSize.s24(context),
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Icon(icon!, color: Colors.white, size: CommonSize.s24(context)),
        ),
      ),
    );
  }
}
