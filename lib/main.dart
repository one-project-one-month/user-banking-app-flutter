import 'package:banking_app/AppStyles/Style.dart';
import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/controller/face_auth_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/service/face_auth_service.dart';
import 'package:banking_app/screens/Nickname/views/nickname_create.dart';
import 'package:banking_app/screens/Nickname/views/nickname_list.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'package:banking_app/screens/Settings/settings_screen.dart';
import 'package:banking_app/screens/Transfer/controllers/transfer_bloc.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_bloc.dart';
import 'package:banking_app/screens/auth/controllers/auth_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
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
        // KYC Blocs
        BlocProvider<UploadBloc>(create: (context) => UploadBloc()),
        BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
        BlocProvider<FaceAuthBloc>(create: (context) => FaceAuthBloc(FaceAuthService())),

        // CORE BLOCS – MUST BE HERE
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
          lazy: false, 
        ),
        BlocProvider<TransferBloc>(
          create: (context) => TransferBloc(),
          lazy : false
        ),
        // (SettingsBloc previously duplicated here — removed to ensure one source of truth)
        BlocProvider<TransferBloc>(create: (context) => TransferBloc()),
        BlocProvider<SettingsBloc>(create: (context) => SettingsBloc()),
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
            home: NicknameListScreen(),
           //TODO: Need to Use Routes
            // onGenerateRoute: AppRoutes.generateRoute,
            // initialRoute: AppRoutes.splash,
          );
        },
      ),
     
    );
  }
}
