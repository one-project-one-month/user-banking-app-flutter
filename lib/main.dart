import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/auth/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide UploadBloc globally so it's accessible across all routes
        BlocProvider<UploadBloc>(create: (context) => UploadBloc()),
        // Provide VerificationBloc globally
        BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
      ],
      child: MaterialApp(
        title: 'Banking App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        // Use named routes for better navigation management
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.splash, 
      ),
    );
  }
}
