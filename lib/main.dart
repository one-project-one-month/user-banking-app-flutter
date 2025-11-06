import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/controller/face_auth_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/service/face_auth_service.dart';
import 'package:banking_app/screens/Settings/views/settings_view.dart';
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
        BlocProvider<UploadBloc>(create: (context) => UploadBloc()),
        BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
        BlocProvider<FaceAuthBloc>(create: (context) => FaceAuthBloc(FaceAuthService())),
      ],
      child: MaterialApp(
        title: 'Banking App',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home:SettingsView()//const SplashScreen(),
        // Use named routes for better navigation management
       // onGenerateRoute: AppRoutes.generateRoute,
       // initialRoute: AppRoutes.splash, 
      ),
    );
  }
}
