// otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/Routes/app_routes.dart';
import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/button.dart';
import '../widgets/flushbar.dart';
import '../widgets/size.dart';

class OtpScreen extends StatefulWidget {
  final String? destination;
  final String? realOtp; // ← FROM BACKEND
  final AuthBloc authBloc;

  const OtpScreen({Key? key, this.destination, this.realOtp, required this.authBloc}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade, _contentFade, _fieldsFade, _buttonFade;
  late Animation<Offset> _logoSlide, _contentSlide, _fieldsSlide, _buttonSlide;

  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();

    // Animations
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25));
    _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.45));
    _fieldsFade = CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.75));
    _buttonFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0));

    _logoSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25)));
    _contentSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.45)));
    _fieldsSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.75)));
    _buttonSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));

    _controller.forward();
    _startResendTimer();

    // SHOW REAL OTP ON SCREEN
    if (widget.realOtp != null && widget.realOtp!.length == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customFlushbar(
          context: context,
          message: 'Your OTP: ${widget.realOtp}',
          backgroundColor: Colors.green,
          icon: const Icon(Icons.key, color: Colors.white),
          duration: const Duration(seconds: 20),
        );
      });
    }
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
    for (final c in _controllers) c.dispose();
    for (final n in _nodes) n.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onFieldChanged(int index, String value) {
    if (value.isEmpty) return;
    if (index < 5) {
      _nodes[index + 1].requestFocus();
    } else {
      _nodes[index].unfocus();
    }
  }

  void _onFieldKey(int index, RawKeyEvent e) {
    if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _nodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  void _submitCode() {
    final cleaned = _code.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 6) {
      customFlushbar(context: context, message: 'Enter all 6 digits');
      return;
    }

    for (final n in _nodes) n.unfocus();

    // USE THE PASSED BLOC — NOT context.read()
    widget.authBloc.add(AuthVerifyOTP(widget.destination ?? '', cleaned));
  }

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return BlocProvider.value(
      value: widget.authBloc,
      child: Scaffold(
      //  extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   backgroundColor: theme.appBarTheme.backgroundColor,
        //   elevation: 0,
        //   leading: IconButton(
        //     icon: Icon(Theme.of(context).platform == TargetPlatform.iOS ? Icons.arrow_back_ios : Icons.arrow_back),
        //     onPressed: () => Navigator.pop(context),
        //     color: theme.colorScheme.onPrimary,
        //   ),
        // ),
        body: Container(
            constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
        
          decoration:  BoxDecoration(
            gradient: LinearGradient(
               colors: [theme.colorScheme.primary, theme.colorScheme.tertiary, theme.colorScheme.primary],
          begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(CommonSize.s20(context)),
              child: SingleChildScrollView(
                 physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
             
                child: Column(
                  children: [
                       Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Theme.of(context).platform == TargetPlatform.iOS ? Icons.arrow_back_ios : Icons.arrow_back,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: CommonSize.s40(context)),
                    // Logo
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child:   theme.colorScheme.brightness == Brightness.dark
                            ? const AppLogo(
                                width: 110,
                                height: 110,
                                borderRadius: 24,
                                showShadow: true,
                              )
                            : const
                        AppLogo2(width: 110, height: 110, borderRadius: 24, showShadow: true),
                   ),
                    ),
                    SizedBox(height: CommonSize.s24(context)),
                            
                    // Title
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            Text(
                              'Enter verification code',
                              style: TextStyle(
                                 color: theme.colorScheme.onPrimary,
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
                                        color: theme.colorScheme.onPrimary,
                                      fontSize: CommonSize.s14(context),
                                    ),
                                  ),
                                  TextSpan(
                                    text: widget.destination ?? 'your email',
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                      fontSize: CommonSize.s16(context),
                                      fontWeight: FontWeight.bold,
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
                            
                    // OTP Fields
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
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style:  TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:  BorderSide(   color: theme.colorScheme.onPrimary.withOpacity(0.5),),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:  BorderSide(color:     theme.colorScheme.onPrimary.withOpacity(0.5)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor:     theme.colorScheme.onPrimary.withOpacity(0.06),
                                  ),
                                  onChanged: (v) => _onFieldChanged(i, v),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    SizedBox(height: CommonSize.s20(context)),
                            
                    // Submit + Resend
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state.status == AuthStatus.success && state.message == 'OTP verified successfully') {
                          customFlushbar(context: context, message: 'Verified!', backgroundColor: Colors.green);
                          Future.delayed(const Duration(seconds: 1), () {
                            AppRoutes.navigateTo(
                              context,
                              AppRoutes.personalInfo,
                              arguments: {'authBloc': widget.authBloc},
                            );
                          });
                        } else if (state.status == AuthStatus.failure) {
                          customFlushbar(
                            context: context,
                            message: state.message ?? 'Failed',
                            backgroundColor: Colors.redAccent,
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state.status == AuthStatus.loading;
                            
                        return FadeTransition(
                          opacity: _buttonFade,
                          child: SlideTransition(
                            position: _buttonSlide,
                            child: Column(
                              children: [
                                customElevatedButton(context: context,
                                  onPressed: _submitCode,
                                  text: 'Verify',
                                   color: theme.colorScheme.onPrimary,
                                  textColor:     theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(CommonSize.s10(context)),
                                  height: CommonSize.s48(context),
                                  width: double.infinity,
                                  isLoading: isLoading,
                                ),
                                SizedBox(height: CommonSize.s12(context)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _secondsLeft > 0 ? 'Resend in $_secondsLeft s' : "Didn't receive?",
                                      style: TextStyle(
                                        color:  theme.colorScheme.onPrimary.withOpacity(0.9),
                                        fontSize: CommonSize.s14(context),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _secondsLeft == 0
                                              ? () {
                                                context.read<AuthBloc>().add(AuthRequestOTP(widget.destination ?? ''));
                                                _startResendTimer();
                                              }
                                              : null,
                                      child: Text(
                                        'Resend',
                                        style: TextStyle(color: _secondsLeft == 0 ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary.withOpacity(0.5),
                                          fontSize: CommonSize.s14(context),
                                          fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
