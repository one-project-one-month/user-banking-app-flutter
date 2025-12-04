import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';
import 'package:banking_app/screens/Main/controllers/user_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/screens/Settings/widgets/set_pin_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _autoSaveReceipt = false;
  bool _notifications = true;
  bool _biometricAuth = false;
  String _language = 'English';
  String _currency = 'MMK (Kyat)';

  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _profileFade;
  late Animation<double> _darkModeFade;
  late Animation<double> _changePwdFade;
  late Animation<double> _selectAccFade;
  late Animation<double> _transPinFade;
  late Animation<double> _nickFade;
  late Animation<double> _logoutFade;
  late Animation<Offset> _profileSlide;
  late Animation<Offset> _darkModeSlide;
  late Animation<Offset> _changePwdSlide;
  late Animation<Offset> _selectAccSlide;
  late Animation<Offset> _transPinSlide;
  late Animation<Offset> _nickSlide;
  late Animation<Offset> _logoutSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    // Create staggered animations
    _profileFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2));
    _darkModeFade = CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.3));
    _changePwdFade = CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.4));
    _selectAccFade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.5));
    _transPinFade = CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.6));
    _nickFade = CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.7));
    _logoutFade = CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.8));

    _profileSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.2)));
    _darkModeSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.3)));
    _changePwdSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.4)));
    _selectAccSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.5)));
    _transPinSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.6)));
    _nickSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.7)));
    _logoutSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.8)));

    _controller.forward();

    // Load settings and auto-save receipt setting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<SettingsBloc>();
      bloc.add(const LoadSettings());

      // Safely try to load auto-save receipt setting
      // This might fail on hot reload if the handler wasn't registered yet
      try {
        bloc.add(const LoadAutoSaveReceipt());
      } catch (e) {
        print('⚠️ Could not load auto-save receipt setting: $e');
        // This is okay - the setting will default to false
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  leading: Radio<String>(
                    value: 'English',
                    groupValue: _language,
                    onChanged: (value) {
                      setState(() => _language = value!);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Myanmar (ဗမာ)'),
                  leading: Radio<String>(
                    value: 'Myanmar',
                    groupValue: _language,
                    onChanged: (value) {
                      setState(() => _language = value!);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Currency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('MMK (Kyat)'),
                  leading: Radio<String>(
                    value: 'MMK (Kyat)',
                    groupValue: _currency,
                    onChanged: (value) {
                      setState(() => _currency = value!);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ListTile(
                  title: const Text('USD (Dollar)'),
                  leading: Radio<String>(
                    value: 'USD (Dollar)',
                    groupValue: _currency,
                    onChanged: (value) {
                      setState(() => _currency = value!);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                ListTile(
                  title: const Text('THB (Baht)'),
                  leading: Radio<String>(
                    value: 'THB (Baht)',
                    groupValue: _currency,
                    onChanged: (value) {
                      setState(() => _currency = value!);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: const Text('Change password feature coming soon'),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const SetPinDialog());
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  // Clear user data
                  context.read<UserBloc>().add(const UserClearData());
                  context.read<SettingsBloc>().add(LogoutPressed());

                  // Navigate to login and clear navigation stack
                  Navigator.of(context).pop(); // Close dialog
                  AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color ?? Colors.black),
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (!mounted || !context.mounted) return;

          if (state.isSuccess && state.message != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: const Color(0xFF16A34A),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          } else if (state.hasError && state.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Card
              FadeTransition(
                opacity: _profileFade,
                child: SlideTransition(
                  position: _profileSlide,
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, userState) {
                      final user = userState.user;
                      final accountNumber = user?.selectedAccountDetails?.accountNumber ?? 'N/A';
                      final fullName = user?.username ?? 'User';

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(accountNumber),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            // TODO: navigate to edit profile
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dark Mode
              FadeTransition(
                opacity: _darkModeFade,
                child: SlideTransition(
                  position: _darkModeSlide,
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: SwitchListTile(
                          title: Text(
                            'Dark Mode',
                            style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: state.darkMode,
                          activeColor: const Color(0xFF3366FF),
                          onChanged: (v) => context.read<SettingsBloc>().add(ToggleDarkMode(v)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Auto Save Receipt Toggle
              FadeTransition(
                opacity: _darkModeFade, // Reuse animation or create new one
                child: SlideTransition(
                  position: _darkModeSlide,
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: SwitchListTile(
                          title: Text(
                            'Auto Save Receipt',
                            style: GoogleFonts.inter(
                              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Automatically save transaction receipts to gallery',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          value: state.autoSaveReceipt,
                          activeColor: const Color(0xFF3366FF),
                          onChanged: (v) => context.read<SettingsBloc>().add(SettingsAutoSaveReceipt(v)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Change Password
              _animatedTile(
                fade: _changePwdFade,
                slide: _changePwdSlide,
                title: 'Change Password',
                onTap: () => _showChangePasswordDialog(context),
              ),

              // Select Account
              _animatedTile(
                fade: _selectAccFade,
                slide: _selectAccSlide,
                title: 'Select Account',
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () {},
              ),

              // Set Transaction PIN
              _animatedTile(
                fade: _transPinFade,
                slide: _transPinSlide,
                title: 'Set Transaction PIN',
                onTap: () => _showSetPinDialog(context),
              ),

              // Nickname
              _animatedTile(
                fade: _nickFade,
                slide: _nickSlide,
                title: 'Nickname',
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.nickname);
                },
              ),

              const SizedBox(height: 10),
              const SizedBox(height: 8),

              FadeTransition(
                opacity: _darkModeFade,
                child: SlideTransition(
                  position: _darkModeSlide,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3366FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.smart_toy, color: Color(0xFF3366FF), size: 20),
                    ),
                    title: const Text('AI Assistant'),
                    onTap: () {
                      AppRoutes.navigateTo(context, AppRoutes.aiAssistant);
                    },
                  ),
                ),
              ),
              // Logout
              FadeTransition(
                opacity: _logoutFade,
                child: SlideTransition(
                  position: _logoutSlide,
                  child: _buildSettingsTile(
                    title: 'Log Out',
                    titleColor: Colors.red,
                    leading: const Icon(Icons.logout, color: Colors.red),
                    onTap: () => _handleLogout(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedTile({
    required Animation<double> fade,
    required Animation<Offset> slide,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildSettingsTile(title: title, trailing: trailing, onTap: onTap),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    Widget? trailing,
    Widget? leading,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: titleColor ?? (Theme.of(context).textTheme.titleLarge?.color ?? Colors.black),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
