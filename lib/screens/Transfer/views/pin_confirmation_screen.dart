import 'package:flutter/material.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'widgets/pin_input_display.dart';
import 'widgets/numeric_keypad.dart';
import 'transaction_success_screen.dart';

class PinConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final VoidCallback? onForgotPin;

  const PinConfirmationScreen({
    super.key,
    this.transactionData,
    this.onSuccess,
    this.onCancel,
    this.onForgotPin,
  });

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attempts = 0;
  bool _isLoading = false;
  bool _isLocked = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKeyPressed(String digit) {
    if (_isLocked || _isLoading) return;

    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
      });

      // Auto-submit when 6 digits are entered
      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_isLocked || _isLoading) return;

    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_isLocked) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate PIN verification (replace with actual backend call)
    final isValidPin =
        _pin == '123456'; // This should be replaced with backend validation

    setState(() {
      _isLoading = false;
    });

    if (isValidPin) {
      // Success - Navigate to transaction success screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => TransactionSuccessScreen(
                transactionData: widget.transactionData,
              ),
        ),
      );
    } else {
      // Failed attempt
      setState(() {
        _attempts++;
        _pin = '';
      });

      if (_attempts >= 3) {
        // Lock screen after 3 attempts
        setState(() {
          _isLocked = true;
        });

        customFlushbar(
          context: context,
          message: "Too many failed attempts. Please try again later.",
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      } else {
        customFlushbar(
          context: context,
          message: "Invalid PIN. ${3 - _attempts} attempts remaining.",
          backgroundColor: Colors.orange,
          icon: const Icon(Icons.warning, color: Colors.white),
        );
      }
    }
  }

  void _handleForgotPin() {
    if (widget.onForgotPin != null) {
      widget.onForgotPin!();
    } else {
      // Default behavior - show dialog or navigate to forgot PIN screen
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Forgot PIN?'),
              content: const Text('Please contact support to reset your PIN.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onCancel ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002D62)),
        ),
        title: const Text(
          'Password',
          style: TextStyle(
            color: Color(0xFF002D62),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(CommonSize.s20(context)),
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lock Icon
                        Container(
                          width: CommonSize.s56(context),
                          height: CommonSize.s56(context),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A3D62),
                            borderRadius: BorderRadius.circular(
                              CommonSize.s12(context),
                            ),
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        SizedBox(height: CommonSize.s24(context)),

                        // Instruction Text
                        Text(
                          'Enter your PIN to confirm transaction',
                          style: TextStyle(
                            color: const Color(0xFF002D62),
                            fontSize: CommonSize.s16(context),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: CommonSize.s32(context)),

                        // PIN Input Display
                        PinInputDisplay(pin: _pin),

                        SizedBox(height: CommonSize.s32(context)),

                        // Numeric Keypad
                        NumericKeypad(
                          onKeyPressed: _onKeyPressed,
                          onBackspace: _onBackspace,
                          isEnabled: !_isLocked && !_isLoading,
                        ),

                        SizedBox(height: CommonSize.s24(context)),

                        // Forgot PIN Link
                        TextButton(
                          onPressed: _isLocked ? null : _handleForgotPin,
                          child: Text(
                            'Forgot Pin?',
                            style: TextStyle(
                              color:
                                  _isLocked
                                      ? Colors.grey
                                      : const Color(0xFF002D62),
                              fontSize: CommonSize.s14(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(bottom: CommonSize.s20(context)),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0A3D62),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
