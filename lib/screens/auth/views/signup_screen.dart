import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/auth/controllers/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/auth_bloc.dart';
import '../controllers/auth_state.dart';
import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<double> _buttonFade;
  late Animation<double> _1TextFieldFade;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _contentSlide;
  late Animation<Offset> _buttonSlide;
  late Animation<Offset> _1TextFieldSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _logoFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut));
    _buttonFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));
    _1TextFieldFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));

    _logoSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)));
    _contentSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)));
    _buttonSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));
    _1TextFieldSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF227DBE), Color.fromARGB(255, 10, 89, 146), Color(0xFF0A3D62)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(CommonSize.s20(context)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Theme.of(context).platform == TargetPlatform.iOS ? Icons.arrow_back_ios : Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: CommonSize.s40(context)),
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: AppLogo(width: 110, height: 110, borderRadius: 24, showShadow: true),
                    ),
                  ),
                  SizedBox(height: CommonSize.s20(context)),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: CommonSize.s28(context),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: CommonSize.s32(context)),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _1TextFieldFade,
                          child: SlideTransition(
                            position: _1TextFieldSlide,
                            child: customTextField(
                              controller: _emailController,
                              errorStyle: const TextStyle(color: Color.fromARGB(255, 240, 252, 2)),
                              hintText: 'Enter your email',
                              textStyle: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email),
                              borderColor: Colors.white,
                              hintStyle: const TextStyle(color: Colors.white),
                              prefixIconColor: Colors.white,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              onEditingComplete: () => FocusScope.of(context).unfocus(),
                              onChanged: (value) {
                                if (_formKey.currentState != null) {
                                  _formKey.currentState!.validate();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: CommonSize.s12(context)),
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Column(
                        children: [
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state.status == AuthStatus.success) {
                                customFlushbar(
                                  context: context,
                                  message: state.message ?? "OTP sent to your email!",
                                  backgroundColor: Colors.green,
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                );

                                // Get the same AuthBloc instance
                                final authBloc = context.read<AuthBloc>();

                                Future.delayed(const Duration(milliseconds: 500), () {
                                  AppRoutes.navigateTo(
                                    context,
                                    AppRoutes.otp,
                                    arguments: {
                                      'destination': _emailController.text.trim(),
                                      'realOtp': state.otpCode,
                                      'authBloc': authBloc, // Pass the bloc
                                    },
                                  );
                                });
                              } else if (state.status == AuthStatus.failure) {
                                customFlushbar(
                                  context: context,
                                  message: state.message ?? "Failed to send OTP",
                                  backgroundColor: Colors.redAccent,
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state.status == AuthStatus.loading;

                              return customElevatedButton(
                                onPressed: () {
                                  if (!isLoading && _formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(AuthRequestOTP(_emailController.text.trim()));
                                  }
                                },
                                text: "Continue",
                                color: Colors.white,
                                textColor: const Color(0xFF1E3C72),
                                borderRadius: BorderRadius.circular(CommonSize.s10(context)),
                                height: CommonSize.s48(context),
                                width: double.infinity,
                                fontSize: CommonSize.s18(context),
                                fontWeight: FontWeight.w600,
                                isLoading: isLoading,
                              );
                            },
                          ),
                          SizedBox(height: CommonSize.s16(context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: CommonSize.s16(context),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => AppRoutes.navigateTo(context, AppRoutes.login),
                                child: Text(
                                  "Log in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: CommonSize.s16(context),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
