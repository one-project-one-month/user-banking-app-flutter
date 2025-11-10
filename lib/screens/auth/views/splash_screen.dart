import 'dart:convert';
import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/constant.dart';
import 'package:banking_app/screens/auth/models/token.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );
    _controller.forward();
    _checkLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    // small delay to show splash
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final tokenJson = prefs.getString('auth_token');
    if (tokenJson != null) {
      try {
        final Map<String, dynamic> map = json.decode(tokenJson);
        final token = Token.fromJson(map);
        if (!token.isExpired) {
          if (!mounted) return;
          AppRoutes.navigateAndReplace(context, AppRoutes.welcome);
         
          return;
        }
      } catch (_) {
        //  parse errors
      }
    }

    if (!mounted) return;
  AppRoutes.navigateAndReplace(context,// AppRoutes.welcome
 AppRoutes.welcome );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
 

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.tertiary, theme.colorScheme.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          children:[ Center(
            child: FadeTransition(
              opacity: _logoFade,
              child: SlideTransition(
                position: _logoSlide,
                child: Image.asset(
                  'assets/font_image/flypay_font.png',
                  width: 150,
                  height: 150,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Positioned(bottom: 10, right: 1,left: 1,child:   Center(child: Text(Constant.appVersion,style: theme.textTheme.bodySmall,)),)
          ]
        ),
      ),
    );
  }
}
