import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:banking_app/screens/Transfer/controllers/transfer_bloc.dart';
import 'package:banking_app/screens/Transfer/controllers/transfer_event.dart';
import 'package:banking_app/screens/Transfer/controllers/transfer_state.dart';
import 'widgets/pin_input_display.dart';
import 'widgets/numeric_keypad.dart';
import 'transaction_success_screen.dart';
import 'package:banking_app/responsive_utils.dart';

class PinConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final VoidCallback? onForgotPin;

  const PinConfirmationScreen({super.key, this.transactionData, this.onSuccess, this.onCancel, this.onForgotPin});

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attempts = 0;
  bool _isLoading = false;
  bool _isLocked = false;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKeyPressed(String digit) {
    if (_isLocked || _isLoading || _pin.length >= 6) return;
    setState(() => _pin += digit);
    if (_pin.length == 6) _verifyAndConfirmTransfer();
  }

  void _onBackspace() {
    if (_isLocked || _isLoading || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verifyAndConfirmTransfer() async {
    if (_isLocked) return;
    setState(() => _isLoading = true);
    context.read<TransferBloc>().add(TransferVerifyPin(_pin));
  }

  void _handlePinVerified() {
    final state = context.read<TransferBloc>().state;
    final recipient = state.recipient;
    final amount = state.transactionAmount;
    final note = state.transactionNote ?? '';

    if (recipient == null || recipient.id.isEmpty || amount == null || amount <= 0) {
      setState(() => _isLoading = false);
      customFlushbar(context: context, message: "Invalid transaction data.", backgroundColor: Colors.red);
      return;
    }

    final toAccountId = int.tryParse(recipient.id);
    if (toAccountId == null) {
      setState(() => _isLoading = false);
      customFlushbar(context: context, message: "Invalid recipient ID", backgroundColor: Colors.red);
      return;
    }

    context.read<TransferBloc>().add(TransferConfirm(toAccountId: toAccountId, amount: amount, note: note, pin: _pin));
  }

  void _handleForgotPin() {
    if (widget.onForgotPin != null) {
      widget.onForgotPin!();
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Forgot PIN?'),
              content: const Text('Please contact support to reset your PIN.'),
              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF0A3D62);

    return BlocListener<TransferBloc, TransferState>(
      listener: (context, state) {
        // Loading states
        if (state.isVerifyingPin || state.isConfirming || state.isValidating) {
          if (!_isLoading) setState(() => _isLoading = true);
        }
        // PIN verified → proceed to confirm transfer
        else if (state.isPinVerified) {
          _handlePinVerified();
        }
        // Transfer confirmed → go to success screen
        else if (state.isConfirmed) {
          setState(() => _isLoading = false);

          final validationData = state.validationData ?? {};
          final confirmationData = state.confirmationData ?? {};
          final fromAccount = validationData['fromAccountDetails'] as Map<String, dynamic>?;
          final toAccount = validationData['toAccountDetails'] as Map<String, dynamic>?;

          final transactionData = {
            'fromName': fromAccount?['accountHolderName'] ?? fromAccount?['accountNumber'] ?? '',
            'fromAccount': fromAccount?['accountNumber'] ?? '',
            'toName': toAccount?['accountHolderName'] ?? state.recipient?.fullName ?? '',
            'toAccount': toAccount?['accountNumber'] ?? state.recipient?.accountNumber ?? '',
            'amount': state.transactionAmount?.toString() ?? '0',
            'currency': 'Ks',
            'note': state.transactionNote ?? '',
            'transactionId': confirmationData['transactionId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          };

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => TransactionSuccessScreen(transactionData: transactionData)),
            (route) => false,
          );
        }
        // Error handling
        else if (state.hasError) {
          setState(() {
            _isLoading = false;
            _attempts++;
            _pin = '';
          });

          if (_attempts >= 3) {
            setState(() => _isLocked = true);
            customFlushbar(
              context: context,
              message: "Too many failed attempts. Account locked.",
              backgroundColor: Colors.red,
            );
          } else {
            customFlushbar(
              context: context,
              message: state.errorMessage ?? "Invalid PIN. ${3 - _attempts} attempts left.",
              backgroundColor: Colors.orange,
            );
          }
        } else {
          if (_isLoading) setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: widget.onCancel ?? () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: primaryColor, size: context.iconSize(24)),
          ),
          title: Text(
            'Password',
            style: TextStyle(color: primaryColor, fontSize: context.fontSize(19), fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: context.responsivePadding(horizontal: 24, bottom: 20),
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
                            width: context.iconSize(64),
                            height: context.iconSize(64),
                            decoration: BoxDecoration(color: primaryColor, borderRadius: context.borderRadius(16)),
                            child: Icon(Icons.lock, color: Colors.white, size: context.iconSize(32)),
                          ),

                          SizedBox(height: context.spacing(28)),

                          Text(
                            'Enter your PIN to confirm transaction',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: context.fontSize(12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: context.spacing(32)),

                          PinInputDisplay(pin: _pin),

                          SizedBox(height: context.spacing(32)),

                          NumericKeypad(
                            onKeyPressed: _onKeyPressed,
                            onBackspace: _onBackspace,
                            isEnabled: !_isLocked && !_isLoading,
                          ),

                          SizedBox(height: context.spacing(24)),

                          TextButton(
                            onPressed: _isLocked ? null : _handleForgotPin,
                            child: Text(
                              'Forgot PIN?',
                              style: TextStyle(
                                color: _isLocked ? Colors.grey : primaryColor,
                                fontSize: context.fontSize(15),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Loading indicator at the very bottom
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.only(top: context.spacing(12)),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A3D62)),
                      strokeWidth: 3.5,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
