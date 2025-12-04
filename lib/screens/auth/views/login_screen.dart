import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_event.dart';
import 'package:banking_app/screens/auth/controllers/auth_state.dart';
import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //for animations
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<double> _buttonFade;
  late Animation<double> _1TextFieldFade;
  late Animation<double> _2TextFieldFade;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _contentSlide;
  late Animation<Offset> _buttonSlide;
  late Animation<Offset> _1TextFieldSlide;
  late Animation<Offset> _2TextFieldSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    // Staggered animation intervals
    _logoFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut));
    _buttonFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));
    _1TextFieldFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));
    _2TextFieldFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));

    // Slide from bottom slightly
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
    _2TextFieldSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginWithCredentials(_emailController.text.trim(), _passwordController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
        decoration: BoxDecoration(
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
                  FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child:
                          theme.colorScheme.brightness == Brightness.dark
                              ? const AppLogo(width: 110, height: 110, borderRadius: 24, showShadow: true)
                              : const AppLogo2(width: 110, height: 110, borderRadius: 24, showShadow: true),
                    ),
                  ),
                  SizedBox(height: CommonSize.s20(context)),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: CommonSize.s28(context),
                          color: theme.colorScheme.onPrimary,
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
                              errorStyle: TextStyle(color: theme.colorScheme.error),
                              hintText: 'Username',
                              textStyle: TextStyle(color: theme.colorScheme.onPrimary),
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icon(Icons.email, color: theme.colorScheme.onPrimary),
                              borderColor: theme.colorScheme.onPrimary,
                              hintStyle: TextStyle(color: theme.colorScheme.onPrimary),
                              prefixIconColor: theme.colorScheme.onPrimary,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                              onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            ),
                          ),
                        ),

                        SizedBox(height: CommonSize.s10(context)),

                        FadeTransition(
                          opacity: _2TextFieldFade,
                          child: SlideTransition(
                            position: _2TextFieldSlide,
                            child: customTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              errorStyle: TextStyle(color: theme.colorScheme.error),
                              textStyle: TextStyle(color: theme.colorScheme.onPrimary),
                              prefixIconColor: theme.colorScheme.onPrimary,
                              suffixIconColor: theme.colorScheme.onPrimary,
                              hintStyle: TextStyle(color: theme.colorScheme.onPrimary),
                              borderColor: theme.colorScheme.onPrimary,
                              keyboardType: TextInputType.text,
                              prefixIcon: Icon(Icons.lock, color: theme.colorScheme.onPrimary),
                              isPassword: true,
                              showPasswordToggle: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                                _handleLogin();
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
                                // ✅ Login successful - token and user data saved to cache
                                customFlushbar(
                                  context: context,
                                  message: "Login Successful!",
                                  backgroundColor: Colors.green,
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                );

                                // Load user data into UserBloc from cache
                                context.read<UserBloc>().add(UserLoadData());

                                // Navigate to home
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    AppRoutes.navigateAndRemoveUntil(context, AppRoutes.home_screen);
                                  }
                                });
                              } else if (state.status == AuthStatus.failure) {
                                // ❌ Login failed - show error from backend
                                customFlushbar(
                                  context: context,
                                  message: state.message ?? "Login Failed",
                                  backgroundColor: Colors.red,
                                  icon: const Icon(Icons.error, color: Colors.white),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state.status == AuthStatus.loading;

                              return customElevatedButton(
                                context: context,
                                onPressed: isLoading ? null : _handleLogin,
                                text: "Login",
                                color: theme.colorScheme.onPrimary,
                                textColor: theme.colorScheme.primary,
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
                                "If you don't have an account? ",
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                                  fontSize: CommonSize.s12(context),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => AppRoutes.navigateTo(context, AppRoutes.signup),
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: CommonSize.s12(context),
                                    decoration: TextDecoration.underline,
                                    decorationColor: theme.colorScheme.onPrimary,
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
