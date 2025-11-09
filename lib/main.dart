import 'package:banking_app/AppStyles/Style.dart';
import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/controller/face_auth_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/service/face_auth_service.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'package:banking_app/screens/Transfer/controllers/transfer_bloc.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_bloc.dart';
import 'package:banking_app/screens/auth/controllers/auth_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
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
        // Settings Bloc - Only once
        BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()..add(LoadSettings())),

        // KYC Blocs
        BlocProvider<UploadBloc>(create: (context) => UploadBloc()),
        BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
        BlocProvider<FaceAuthBloc>(create: (context) => FaceAuthBloc(FaceAuthService())),

        // Core Auth & User Blocs
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<UserBloc>(create: (context) => UserBloc(), lazy: false),

        // Transfer Bloc - Only once
        BlocProvider<TransferBloc>(create: (context) => TransferBloc(), lazy: false),

        // Transaction Bloc (if needed)
         BlocProvider<TransactionBloc>(create: (context) => TransactionBloc()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isDark = settingsState.darkMode;
          return MaterialApp(
            title: 'Banking App',
            theme: appLightTheme,
            darkTheme: appDarkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.splash,
          );
        },
      ),
    );
  }
}
