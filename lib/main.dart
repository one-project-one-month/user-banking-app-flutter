import 'package:banking_app/AppStyles/Style.dart';
import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/constant.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/controller/face_auth_bloc.dart';
import 'package:banking_app/screens/KYC/face_authentication/service/face_auth_service.dart';
import 'package:banking_app/screens/Main/home_screen.dart';
import 'package:banking_app/screens/Nickname/views/nickname_create.dart';
import 'package:banking_app/screens/Nickname/views/nickname_list.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'package:banking_app/screens/Transfer/controllers/transfer_bloc.dart';
import 'package:banking_app/screens/auth/controllers/auth_bloc.dart';
import 'package:banking_app/screens/views/splash_screen.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/auth/services/cache_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧩 Load theme setting before runApp to avoid flash
  final cache = CacheService();
  const initKey = '_settings_initialized';
  final initialized = await cache.getBool(initKey);

  bool darkMode = false;
  bool autoSave = false;

  if (initialized == null || initialized == false) {
    // First launch → set defaults
    await cache.setBool(Constant.cacheSettingDarkModeKey, darkMode);
    await cache.setBool(Constant.cacheSettingAutoSaveKey, autoSave);
    await cache.setBool(initKey, true);
  } else {
    // Subsequent launch → read from cache
    darkMode = await cache.getBool(Constant.cacheSettingDarkModeKey) ?? false;
    autoSave = await cache.getBool(Constant.cacheSettingAutoSaveKey) ?? false;
  }

  final initialState = SettingsState.initial().copyWith(
    darkMode: darkMode,
    autoSave: autoSave,
  );

  final settingsBloc = SettingsBloc(cacheService: cache, initialState: initialState);

  runApp(MyApp(settingsBloc: settingsBloc));
}

class MyApp extends StatelessWidget {
  final SettingsBloc settingsBloc;

  const MyApp({super.key, required this.settingsBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>.value(value: settingsBloc),

        // Other Blocs
        BlocProvider<UploadBloc>(create: (_) => UploadBloc()),
        BlocProvider<VerificationBloc>(create: (_) => VerificationBloc()),
        BlocProvider<FaceAuthBloc>(create: (_) => FaceAuthBloc(FaceAuthService())),
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<UserBloc>(create: (_) => UserBloc(), lazy: false),
        BlocProvider<TransferBloc>(create: (_) => TransferBloc()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isDark = settingsState.darkMode;
          return MaterialApp(
            title: Constant.appName,
            theme: appLightTheme,
            darkTheme: appDarkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home:  SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
            initialRoute: AppRoutes.splash
          );
        },
      ),
    );
  }
}
