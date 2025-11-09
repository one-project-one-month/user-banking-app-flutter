// import 'package:banking_app/screens/auth/controllers/auth_bloc.dart';
// import 'package:banking_app/screens/auth/controllers/auth_event.dart';
// import 'package:banking_app/screens/auth/controllers/auth_state.dart';
// import 'package:banking_app/screens/auth/views/personalinfo_screen.dart';
// import 'package:banking_app/screens/auth/widgets/flushbar.dart';
// import 'package:flutter/material.dart';

// import 'package:banking_app/screens/auth/widgets/app_logo.dart';
// import 'package:banking_app/screens/auth/widgets/button.dart';
// import 'package:banking_app/screens/auth/widgets/size.dart';
// import 'package:banking_app/screens/auth/widgets/textfield.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class CreatePasswordScreen extends StatefulWidget {
//   const CreatePasswordScreen({Key? key}) : super(key: key);

//   @override
//   State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
// }

// class _CreatePasswordScreenState extends State<CreatePasswordScreen> with SingleTickerProviderStateMixin {
//   final _pwdController = TextEditingController();
//   final _confirmController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   late AnimationController _controller;
//   late Animation<double> _logoFade;
//   late Animation<double> _contentFade;
//   late Animation<double> _fieldsFade;
//   late Animation<double> _buttonFade;
//   late Animation<Offset> _logoSlide;
//   late Animation<Offset> _contentSlide;
//   late Animation<Offset> _fieldsSlide;
//   late Animation<Offset> _buttonSlide;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

//     _logoFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25));
//     _contentFade = CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.45));
//     _fieldsFade = CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.75));
//     _buttonFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0));

//     _logoSlide = Tween(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25)));
//     _contentSlide = Tween(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.45)));
//     _fieldsSlide = Tween(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.35, 0.75)));
//     _buttonSlide = Tween(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _pwdController.dispose();
//     _confirmController.dispose();
//     super.dispose();
//   }

//   void _submit(BuildContext ctx) {
//     if (!_formKey.currentState!.validate()) return;
//     ctx.read<AuthBloc>().add(AuthCreatePassword(_confirmController.text.trim()));
//   }

//   String? _validatePassword(String? v) {
//     if (v == null || v.isEmpty) return 'Please enter a password';
//     if (v.length < 6) return 'Password must be at least 6 characters';
//     return null;
//   }

//   String? _validateConfirm(String? v) {
//     if (v == null || v.isEmpty) return 'Please confirm your password';
//     if (v != _pwdController.text) return 'Passwords do not match';
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AuthBloc(),
//       child: Builder(
//         builder: (context) {
//           return Scaffold(
//             extendBodyBehindAppBar: true,

//             appBar: AppBar(
//               automaticallyImplyLeading: false,
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               iconTheme: const IconThemeData(color: Colors.white),
//             ),
//             body: Container(
//               constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFF227DBE), Color.fromARGB(255, 10, 89, 146), Color(0xFF0A3D62)],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: SafeArea(
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.all(CommonSize.s20(context)),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         FadeTransition(
//                           opacity: _logoFade,
//                           child: SlideTransition(
//                             position: _logoSlide,
//                             child: AppLogo(width: 90, height: 90, borderRadius: 20),
//                           ),
//                         ),
//                         SizedBox(height: CommonSize.s24(context)),
//                         FadeTransition(
//                           opacity: _contentFade,
//                           child: SlideTransition(
//                             position: _contentSlide,
//                             child: Column(
//                               children: [
//                                 Text(
//                                   'Create a password',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: CommonSize.s20(context),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: CommonSize.s8(context)),
//                                 Text(
//                                   'Choose a strong password to secure your account',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.9),
//                                     fontSize: CommonSize.s14(context),
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: CommonSize.s28(context)),
//                         Form(
//                           key: _formKey,
//                           child: BlocConsumer<AuthBloc, AuthState>(
//                             listener: (context, state) {
//                               if (state.status == AuthStatus.success) {
//                                 customFlushbar(
//                                   context: context,
//                                   message: "Password created successfully",
//                                   backgroundColor: Colors.green,
//                                   icon: const Icon(Icons.check_circle, color: Colors.white),
//                                 );

//                                 // Future.delayed(const Duration(seconds: 1), () {
//                                 //   Navigator.pushReplacement(
//                                 //     context,
//                                 //     MaterialPageRoute(
//                                 //       builder: (_) => PersonalInfoScreen(),
//                                 //     ),
//                                 //   );
//                                 // });
//                               } else if (state.status == AuthStatus.failure) {
//                                 customFlushbar(
//                                   context: context,
//                                   message: state.message ?? 'Password creation failed, Retry',
//                                 );
//                               }
//                             },
//                             builder: (context, state) {
//                               return FadeTransition(
//                                 opacity: _fieldsFade,
//                                 child: SlideTransition(
//                                   position: _fieldsSlide,
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text('Password', style: TextStyle(color: Colors.white)),
//                                       SizedBox(height: CommonSize.s8(context)),
//                                       customTextField(
//                                         controller: _pwdController,
//                                         hintText: 'Enter password',
//                                         isPassword: true,
//                                         showPasswordToggle: true,
//                                         borderColor: Colors.white,
//                                         hintStyle: const TextStyle(color: Colors.white54),
//                                         textStyle: const TextStyle(color: Colors.white),
//                                         validator: _validatePassword,
//                                         onEditingComplete: () => FocusScope.of(context).nextFocus(),
//                                       ),
//                                       SizedBox(height: CommonSize.s16(context)),
//                                       Text('Confirm password', style: TextStyle(color: Colors.white)),
//                                       SizedBox(height: CommonSize.s8(context)),
//                                       customTextField(
//                                         controller: _confirmController,
//                                         hintText: 'Confirm password',
//                                         isPassword: true,
//                                         showPasswordToggle: true,
//                                         borderColor: Colors.white,
//                                         hintStyle: const TextStyle(color: Colors.white54),
//                                         textStyle: const TextStyle(color: Colors.white),
//                                         validator: _validateConfirm,
//                                         onEditingComplete: () {
//                                           _submit(context);
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         SizedBox(height: CommonSize.s28(context)),
//                         FadeTransition(
//                           opacity: _buttonFade,
//                           child: SlideTransition(
//                             position: _buttonSlide,
//                             child: customElevatedButton(
//                               onPressed: () {
//                                 _submit(context);
//                               },
//                               text: 'Create password',
//                               color: Colors.white,
//                               textColor: const Color(0xFF1E3C72),
//                               borderRadius: BorderRadius.circular(CommonSize.s10(context)),
//                               height: CommonSize.s48(context),
//                               width: double.infinity,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }