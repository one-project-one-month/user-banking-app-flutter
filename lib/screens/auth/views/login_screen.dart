import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/auth/controllers/auth_state.dart';
import 'package:banking_app/screens/auth/views/signup_screen.dart';
import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/flushbar.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Staggered animation intervals
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _1TextFieldFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _2TextFieldFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    // Slide from bottom slightly
    _logoSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );
    _contentSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)),
    );
    _buttonSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );
    _1TextFieldSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );
    _2TextFieldSlide = Tween(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
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
            child: Padding(
              padding: EdgeInsets.all(CommonSize.s20(context)),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentGeometry.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Theme.of(context).platform == TargetPlatform.iOS
                              ? Icons.arrow_back_ios
                              : Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: CommonSize.s40(context)),
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: AppLogo(
                          width: 110,
                          height: 110,
                          borderRadius: 24,
                          showShadow: true,
                        ),
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: CommonSize.s32(context)),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeTransition(
                            opacity: _1TextFieldFade,
                            child: SlideTransition(
                              position: _1TextFieldSlide,
                              child: customTextField(
                                controller: _emailController,
                                errorStyle: const TextStyle(
                                  color: Color.fromARGB(255, 240, 252, 2),
                                ),
                                hintText: 'Username',
                                textStyle: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email),
                                borderColor: Colors.white,
                                hintStyle: const TextStyle(color: Colors.white),
                                prefixIconColor: Colors.white,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }

                                  return null;
                                },
                                onEditingComplete:
                                    () => FocusScope.of(context).nextFocus(),
                                // onChanged: (value) {
                                //   // Trigger validator on every change
                                //   if (_formKey.currentState != null) {
                                //     _formKey.currentState!.validate();
                                //   }
                                // },
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
                                errorStyle: const TextStyle(
                                  color: Color.fromARGB(255, 240, 252, 2),
                                ),
                                textStyle: const TextStyle(color: Colors.white),
                                prefixIconColor: Colors.white,
                                suffixIconColor: Colors.white,
                                hintStyle: const TextStyle(color: Colors.white),
                                borderColor: Colors.white,
                                keyboardType: TextInputType.text,
                                prefixIcon: const Icon(Icons.lock),
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
                                // onChanged: (value) {
                                //   // Trigger validator on every change
                                //   if (_formKey.currentState != null) {
                                //     _formKey.currentState!.validate();
                                //   }
                                // },
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      AuthLoginWithCredentials(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                      ),
                                    );
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
                                    message: "Login Successful!",
                                    backgroundColor: Colors.green,
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                  );
                                  // navigate to home
                                  AppRoutes.navigateTo(
                                    context,
                                    AppRoutes.main,
                                  );
                                } else if (state.status == AuthStatus.failure) {
                                  customFlushbar(
                                    context: context,
                                    message: state.message ?? "Login Failed",
                                  );
                                }
                              },
                              builder: (context, state) {
                                final isLoading =
                                    state.status == AuthStatus.loading;

                                return customElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        AuthLoginWithCredentials(
                                          _emailController.text.trim(),
                                          _passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                                  text: "Login",
                                  color: Colors.white,
                                  textColor: const Color(0xFF1E3C72),
                                  borderRadius: BorderRadius.circular(
                                    CommonSize.s10(context),
                                  ),
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
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: CommonSize.s16(context),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    AppRoutes.navigateTo(context, AppRoutes.login);
                                  },
                                  child: Text(
                                    "Sign up",
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
      ),
    );
  }
}
