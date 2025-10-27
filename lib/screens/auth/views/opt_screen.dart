import 'dart:async';

import 'package:banking_app/screens/auth/controllers/auth_bloc.dart';
import 'package:banking_app/screens/auth/controllers/auth_event.dart';
import 'package:banking_app/screens/auth/controllers/auth_state.dart';
import 'package:banking_app/screens/auth/views/createpwd_screen.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String? destination; // phone or email shown to user

  const OtpScreen({Key? key, this.destination}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<double> _fieldsFade;
  late Animation<double> _buttonFade;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _contentSlide;
  late Animation<Offset> _fieldsSlide;
  late Animation<Offset> _buttonSlide;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.45),
    );
    _fieldsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75),
    );
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0),
    );

    _logoSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25)),
    );
    _contentSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.45)),
    );
    _fieldsSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.75)),
    );
    _buttonSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );

    _controller.forward();

    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() => _secondsLeft = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onFieldChanged(int index, String value, BuildContext ctx) {
    if (value.isEmpty) return;
    // move to next
    if (index + 1 < _nodes.length) {
      _nodes[index + 1].requestFocus();
    } else {
      _nodes[index].unfocus();
    }

    // if filled, and all are non-empty, submit
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _submitCode(ctx);
    }
  }

  void _onFieldKey(int index, RawKeyEvent e) {
    if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _nodes[index - 1].requestFocus();
        _controllers[index - 1].text = '';
      }
    }
  }

  void _submitCode(BuildContext ctx) {
    final entered = _code;
    final dest = widget.destination ?? '';

    // Basic validation: ensure 4-6 digits
    final cleaned = entered.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 4 || cleaned.length > 6) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-6 digit code')),
      );
      return;
    }

    // Unfocus fields and dispatch the event
    for (final n in _nodes) {
      n.unfocus();
    }

    ctx.read<AuthBloc>().add(AuthConfirmOTP(dest, cleaned));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF227DBE),
                    Color.fromARGB(255, 10, 89, 146),
                    Color(0xFF0A3D62),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(CommonSize.s20(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _logoFade,
                          child: SlideTransition(
                            position: _logoSlide,
                            child: AppLogo(
                              width: 90,
                              height: 90,
                              borderRadius: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: CommonSize.s24(context)),
                        FadeTransition(
                          opacity: _contentFade,
                          child: SlideTransition(
                            position: _contentSlide,
                            child: Column(
                              children: [
                                Text(
                                  'Enter verification code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: CommonSize.s20(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: CommonSize.s8(context)),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'We sent a 6-digit code to ',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: CommonSize.s14(context),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            widget.destination ??
                                            'your phone/email',
                                        style: TextStyle(
                                          color: Colors.amberAccent,
                                          fontSize: CommonSize.s14(context),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: CommonSize.s28(context)),
                        FadeTransition(
                          opacity: _fieldsFade,
                          child: SlideTransition(
                            position: _fieldsSlide,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) {
                                return SizedBox(
                                  width: CommonSize.s48(context),
                                  child: RawKeyboardListener(
                                    focusNode: FocusNode(),
                                    onKey: (e) => _onFieldKey(i, e),
                                    child: TextField(
                                      controller: _controllers[i],
                                      focusNode: _nodes[i],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white24,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(
                                          0.06,
                                        ),
                                      ),
                                      onChanged:
                                          (v) => _onFieldChanged(i, v, context),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        SizedBox(height: CommonSize.s20(context)),

                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state.status == AuthStatus.success) {
                              customFlushbar(
                                context: context,
                                message: "'OTP verified successfully'",
                                backgroundColor: Colors.green,
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreatePasswordScreen(),
                                  ),
                                );
                              });
                            } else if (state.status == AuthStatus.failure) {
                              customFlushbar(
                                context: context,
                                message:
                                    state.message ??
                                    'OTP verification failed, Retry',
                              );
                            }
                          },
                          builder: (context, state) {
                            return FadeTransition(
                              opacity: _buttonFade,
                              child: SlideTransition(
                                position: _buttonSlide,
                                child: Column(
                                  children: [
                                    customElevatedButton(
                                      onPressed: () {
                                        if (_controllers.every(
                                          (c) => c.text.isNotEmpty,
                                        )) {
                                          _submitCode(context);
                                        }
                                      },
                                      text: 'Verify',
                                      color: Colors.white,
                                      textColor: const Color(0xFF1E3C72),
                                      borderRadius: BorderRadius.circular(
                                        CommonSize.s10(context),
                                      ),
                                      height: CommonSize.s48(context),
                                      width: double.infinity,
                                    ),
                                    SizedBox(height: CommonSize.s12(context)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _secondsLeft > 0
                                              ? 'Resend in $_secondsLeft s'
                                              : 'Didn\'t receive the code?',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: CommonSize.s14(context),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed:
                                              _secondsLeft == 0
                                                  ? () {
                                                    context.read<AuthBloc>().add(
                                                      AuthRequestOTP(
                                                        widget.destination ??
                                                            '',
                                                      ),
                                                    );
                                                    _startResendTimer();
                                                  }
                                                  : null,
                                          child: Text(
                                            'Resend',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: CommonSize.s14(context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
