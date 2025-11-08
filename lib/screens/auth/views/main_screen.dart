// import 'package:banking_app/Routes/app_routes.dart';
// import 'package:banking_app/screens/auth/views/signup_screen.dart';
// import 'package:banking_app/screens/auth/widgets/app_logo.dart';
// import 'package:banking_app/screens/auth/widgets/button.dart';
// import 'package:banking_app/screens/auth/widgets/size.dart';
// import 'package:flutter/material.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _logoFade;
//   late Animation<double> _contentFade;
//   late Animation<double> _buttonFade;
//   late Animation<Offset> _logoSlide;
//   late Animation<Offset> _contentSlide;
//   late Animation<Offset> _buttonSlide;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

//     // Staggered animation intervals
//     _logoFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
//     _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut));
//     _buttonFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut));

//     // Slide from bottom slightly
//     _logoSlide = Tween(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)));
//     _contentSlide = Tween(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)));
//     _buttonSlide = Tween(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       body: Container(
//         decoration:  BoxDecoration(
//           gradient: LinearGradient(
//             colors: [theme.colorScheme.primary, theme.colorScheme.tertiary, theme.colorScheme.primary],
//           begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: CommonSize.s20(context)),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox(height: CommonSize.s20(context)),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       FadeTransition(
//                         opacity: _logoFade,
//                         child: SlideTransition(
//                           position: _logoSlide,
//                           child: AppLogo(width: 110, height: 110, borderRadius: 24, showShadow: true),
//                         ),
//                       ),
//                       SizedBox(height: CommonSize.s32(context)),
//                       FadeTransition(
//                         opacity: _contentFade,
//                         child: SlideTransition(
//                           position: _contentSlide,
//                           child: Column(
//                             children: [
//                               Text(
//                                 "Move Money\nAnywhere, Instantly",
//                                 textAlign: TextAlign.center,
//                                 style: theme.textTheme.headlineMedium
                            
//                               ),
//                               SizedBox(height: CommonSize.s16(context)),
//                               Text(
//                                 "Secure. Fast. Borderless.",
//                                 style: TextStyle(fontSize: CommonSize.s16(context), color: theme.colorScheme.onPrimary.withOpacity(0.8)),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 FadeTransition(
//                   opacity: _buttonFade,
//                   child: SlideTransition(
//                     position: _buttonSlide,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         customElevatedButton(
//                           // onPressed: () {
//                           //   AppRoutes.navigateTo(
//                           //     context,
//                           //     AppRoutes.personalInfo,
//                           //   );
//                           // },
//                           onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
//                           text: "Create Account",
//                           color: theme.colorScheme.onPrimary,
//                           textColor: theme.colorScheme.primary,
//                           borderRadius: BorderRadius.circular(CommonSize.s10(context)),
//                           height: CommonSize.s48(context),
//                           width: double.infinity,
//                           fontSize: CommonSize.s18(context),
//                           fontWeight: FontWeight.w600,
//                         ),
//                         SizedBox(height: CommonSize.s12(context)),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Already have an account? ",
//                               style: TextStyle(color: theme.colorScheme.onPrimary.withOpacity(0.9), fontSize: CommonSize.s16(context)),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 AppRoutes.navigateTo(context, AppRoutes.login);
//                               },
//                               child: Text(
//                                 "Log in",
//                                 style: TextStyle(
//                                   color: theme.colorScheme.onPrimary,
//                                   fontSize: CommonSize.s16(context),
//                                   decoration: TextDecoration.underline,
//                                   decorationColor: theme.colorScheme.onPrimary,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: CommonSize.s16(context)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
