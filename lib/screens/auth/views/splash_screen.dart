import 'dart:convert';
import 'package:banking_app/screens/auth/views/main_screen.dart';
import 'package:banking_app/screens/home/home_screen.dart';
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
    //// small delay to show splash
    await Future.delayed(const Duration(seconds: 2));
    // final prefs = await SharedPreferences.getInstance();
    // final tokenJson = prefs.getString('auth_token');
    // if (tokenJson != null) {
    //   try {
    //     final Map<String, dynamic> map = json.decode(tokenJson);
    //     final token = Token.fromJson(map);
    //     if (!token.isExpired) {
    //       if (!mounted) return;
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(builder: (_) => const HomeScreen()),
    //       );
    //       return;
    //     }
    //   } catch (_) {
    //     //  parse errors
    //   }
    // }

    //if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // Color.fromARGB(255, 106, 156, 202),
              Color(0xFF227DBE),
              Color.fromARGB(255, 10, 89, 146),
              Color(0xFF0A3D62),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: Center(
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
      ),
    );
  }
}
