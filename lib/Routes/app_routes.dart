import 'package:banking_app/screens/Chat/controllers/ai_assistant_bloc.dart';
import 'package:banking_app/screens/Chat/views/ai_chat_assistant_screen.dart';
import 'package:banking_app/screens/KYC/document/views/documentVerification_screen.dart';
import 'package:banking_app/screens/KYC/face_authentication/face_authentication_notice_screen.dart';
import 'package:banking_app/screens/KYC/face_authentication/face_authentication_screen.dart';
import 'package:banking_app/screens/KYC/document/views/upload_document.dart';
import 'package:banking_app/screens/KYC/document/views/upload_document_dl.dart';
import 'package:banking_app/screens/KYC/document/views/upload_document_passport.dart';
import 'package:banking_app/screens/KYC/face_authentication/let_start_screen.dart';
import 'package:banking_app/screens/Main/home_screen.dart';
import 'package:banking_app/screens/Nickname/views/nickname_list.dart';
import 'package:banking_app/screens/QR/qr.dart';
import 'package:banking_app/screens/Settings/settings_screen.dart';
import 'package:banking_app/screens/Transfer/views/transfer_screen.dart';
import 'package:banking_app/screens/auth/controllers/auth_bloc.dart';
import 'package:banking_app/screens/auth/views/login_screen.dart';
import 'package:banking_app/screens/auth/views/welcome_screen.dart';
import 'package:banking_app/screens/auth/views/opt_screen.dart';
import 'package:banking_app/screens/auth/views/personalinfo_screen.dart';
import 'package:banking_app/screens/auth/views/signup_screen.dart';
import 'package:banking_app/screens/auth/views/splash_screen.dart';
import 'package:banking_app/screens/Transfer/views/pin_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoutes {
  // Route names as constants
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String uploadDocument = '/upload-document';
  static const String uploadDocumentDL = '/upload-document-dl';
  static const String uploadDocumentPP = '/upload-document-pp';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String login = '/login';
  static const String personalInfo = '/personal-info';
  static const String documentVerification = '/document-verification';
  static const String faceAuthenticationNotice = '/face-authentication-notice';
  static const String faceAuthentication = '/face-authentication';
  static const String faceAuthLetStart = '/face-auth-let-start';
  static const String qr = '/qr';
  static const String home_screen = '/home-screen';
  static const String transfer = '/transfer';
  static const String pin = '/pin';
  static const String settings = '/settings';
  static const String nickname = '/nickname';
  static const String aiAssistant = '/ai-assistant';

  // Add more routes as your app grows
  // static const String login = '/login';

  // Generate routes - central routing logic
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);

      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen(), settings: settings);
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen(), settings: settings);
      case aiAssistant:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(create: (context) => AIAssistantBloc(), child: const AIAssistantChatScreen()),
          settings: settings,
        );
      case AppRoutes.otp:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => OtpScreen(destination: args['destination'], realOtp: args['realOtp'], authBloc: args['authBloc']),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen(), settings: settings);
      case nickname:
        return MaterialPageRoute(builder: (_) => const NicknameListScreen(), settings: settings);

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);
      case AppRoutes.home_screen:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);

      case AppRoutes.transfer:
        return MaterialPageRoute(builder: (_) => const TransferScreen(), settings: settings);

      case AppRoutes.pin:
        return MaterialPageRoute(builder: (_) => const PinConfirmationScreen(), settings: settings);
      case AppRoutes.personalInfo:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => PersonalInfoScreen(authBloc: args!['authBloc'] as AuthBloc));
      case uploadDocument:
        return MaterialPageRoute(builder: (_) => const UploadDocument(), settings: settings);

      case uploadDocumentDL:
        return MaterialPageRoute(builder: (_) => const UploadDocumentDl(), settings: settings);

      case uploadDocumentPP:
        return MaterialPageRoute(builder: (_) => const UploadDocumentPp(), settings: settings);

      case documentVerification:
        return MaterialPageRoute(builder: (_) => const DocumentVerificationScreen(), settings: settings);
      case faceAuthenticationNotice:
        return MaterialPageRoute(builder: (_) => const FaceAuthenticationNoticeScreen(), settings: settings);
      case faceAuthentication:
        return MaterialPageRoute(builder: (_) => const FaceAuthenticationScreen(), settings: settings);
      case faceAuthLetStart:
        return MaterialPageRoute(builder: (_) => const LetsStartScreen(), settings: settings);
      case qr:
        return MaterialPageRoute(builder: (_) => const QRScreen(), settings: settings);
      // 404 - Route not found
      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  Scaffold(appBar: AppBar(title: const Text('404')), body: const Center(child: Text('Page not found'))),
          settings: settings,
        );
    }
  }

  // Navigate to a route
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  // Navigate and replace current route
  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, Object?>(context, routeName, arguments: arguments);
  }

  // Navigate and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(context, routeName, (route) => false, arguments: arguments);
  }

  // Go back
  static void goBack(BuildContext context, {Object? result}) {
    Navigator.pop(context, result);
  }

  static Future<void> navigateToUploadDocument(BuildContext context) {
    return navigateTo(context, uploadDocument);
  }

  static Future<void> navigateToUploadDL(BuildContext context) {
    return navigateTo(context, uploadDocumentDL);
  }

  static Future<void> navigateToUploadPP(BuildContext context) {
    return navigateTo(context, uploadDocumentPP);
  }

  // Navigate to splash (useful for logout or restart)
  static Future<void> navigateToSplashAndClear(BuildContext context) {
    return navigateAndRemoveUntil(context, splash);
  }

  // Example: Navigate with result callback
  static Future<bool?> navigateToUploadDLWithResult(BuildContext context) async {
    final result = await navigateTo<bool>(context, uploadDocumentDL);
    return result;
  }
}
