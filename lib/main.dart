import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/controllers/upload_bloc.dart';
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
        // Add other BLoCs here as your app grows
        // BlocProvider<AuthBloc>(
        //   create: (context) => AuthBloc(),
        // ),
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
      ),
    );
  }
}
