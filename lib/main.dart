import 'package:banking_app/screens/KYC/document/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/controller/face_auth_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/service/face_auth_service.dart';
import 'package:banking_app/screens/Settings/views/settings_view.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/AppStyles/Style.dart';
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
        BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()..add(LoadSettings())),
        BlocProvider<UploadBloc>(create: (context) => UploadBloc()),
        BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
        BlocProvider<FaceAuthBloc>(create: (context) => FaceAuthBloc(FaceAuthService())),
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
            home: SettingsView(),
            // Use named routes for better navigation management
            // onGenerateRoute: AppRoutes.generateRoute,
            // initialRoute: AppRoutes.splash,
          );
        },
      ),
    );
  }
}
