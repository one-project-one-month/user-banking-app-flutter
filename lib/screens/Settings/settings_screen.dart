import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_event.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/settings_bloc.dart';
import 'controllers/settings_event.dart';
import 'controllers/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  // ──────────────────────────────────────────────────────────────
  //  Animation controller & definitions
  // ──────────────────────────────────────────────────────────────
  late final AnimationController _controller;
  late final Animation<double> _profileFade;
  late final Animation<Offset> _profileSlide;

  late final Animation<double> _darkModeFade;
  late final Animation<Offset> _darkModeSlide;

  late final Animation<double> _autoSaveFade;
  late final Animation<Offset> _autoSaveSlide;

  late final Animation<double> _changePwdFade;
  late final Animation<Offset> _changePwdSlide;

  late final Animation<double> _selectAccFade;
  late final Animation<Offset> _selectAccSlide;

  late final Animation<double> _transPinFade;
  late final Animation<Offset> _transPinSlide;

  late final Animation<double> _nickFade;
  late final Animation<Offset> _nickSlide;

  late final Animation<double> _logoutFade;
  late final Animation<Offset> _logoutSlide;

  @override
  void initState() {
    super.initState();

    // 1 second total, reverse on dispose
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    // Helper to create staggered fade + slide for each row
    Animation<double> _fade(int begin, int end) => Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(begin / 100, end / 100, curve: Curves.easeOut)));

    Animation<Offset> _slide(int begin, int end) => Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Interval(begin / 100, end / 100, curve: Curves.easeOut)));

    // Stagger values (0-100)
    _profileFade = _fade(0, 25);
    _profileSlide = _slide(0, 25);

    _darkModeFade = _fade(10, 35);
    _darkModeSlide = _slide(10, 35);

    _autoSaveFade = _fade(15, 40);
    _autoSaveSlide = _slide(15, 40);

    _changePwdFade = _fade(20, 45);
    _changePwdSlide = _slide(20, 45);

    _selectAccFade = _fade(25, 50);
    _selectAccSlide = _slide(25, 50);

    _transPinFade = _fade(30, 55);
    _transPinSlide = _slide(30, 55);

    _nickFade = _fade(35, 60);
    _nickSlide = _slide(35, 60);

    _logoutFade = _fade(55, 80);
    _logoutSlide = _slide(55, 80);

    // Start the animation when the screen appears
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  //  UI
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        title:  Text('Settings', style: GoogleFonts.inter(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color ?? Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ───── Profile Card ─────
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
                          child: Icon(Icons.person, color: Colors.white),
                          backgroundColor: Colors.blue,
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

            // ───── Dark Mode ─────
            FadeTransition(
              opacity: _darkModeFade,
              child: SlideTransition(
                position: _darkModeSlide,
                child: 
                 BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return 
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: state.darkMode,
                    activeColor: Color(0xFF3366FF),
                    onChanged: (v) => context.read<SettingsBloc>().add(ToggleDarkMode(v)),
                );}),
              ),
            ),

            // ───── Auto Save E-Script ─────
            FadeTransition(
              opacity: _autoSaveFade,
              child: SlideTransition(
                position: _autoSaveSlide,
                child: SwitchListTile(
                  title: const Text('Auto Save E-Script'),
                  value: true,
                  onChanged: (val) {},
                  activeColor: Colors.blue,
                ),
              ),
            ),

            // ───── Change Password ─────
            _animatedTile(
              fade: _changePwdFade,
              slide: _changePwdSlide,
              title: 'Change Password',
              onTap: () => _showChangePasswordDialog(context),
            ),

            // ───── Select Account (dropdown) ─────
            _animatedTile(
              fade: _selectAccFade,
              slide: _selectAccSlide,
              title: 'Select Account',
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () {},
            ),

            // ───── Set Transaction Pin ─────
            _animatedTile(
              fade: _transPinFade,
              slide: _transPinSlide,
              title: 'Set Transaction PIN',
              onTap: () => _showSetPinDialog(context),
            ),

            // ───── Nickname ─────
            _animatedTile(fade: _nickFade, slide: _nickSlide, title: 'Nickname', onTap: () {}),

            const SizedBox(height: 10),

            // ───── Logout ─────
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
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Helper widgets
  // ──────────────────────────────────────────────────────────────
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
        child: _buildSettingsTile(title: title, trailing: trailing, onTap: onTap),
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
        title: Text(title, style:
        GoogleFonts.inter(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black, fontWeight: FontWeight.w500),),
      //   TextStyle(color: titleColor ?? Colors.black, fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  Dialogs & Handlers
  // ──────────────────────────────────────────────────────────────

  void _showSetPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SettingsBloc>(),
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'PIN set successfully'), backgroundColor: Colors.green),
              );
            } else if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Failed to set PIN'), backgroundColor: Colors.red),
              );
            }
          },
          child: AlertDialog(
            title: const Text('Set Transaction PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pinController,
                  decoration: const InputDecoration(labelText: 'PIN', hintText: 'Enter 4-6 digit PIN'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPinController,
                  decoration: const InputDecoration(labelText: 'Confirm PIN', hintText: 'Re-enter PIN'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (pinController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a PIN'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            if (pinController.text != confirmPinController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PINs do not match'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            context.read<SettingsBloc>().add(SettingsSetPin(pinController.text));
                          },
                    child: state.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : const Text('Set PIN'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<SettingsBloc>(),
        child: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state.isSuccess) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Password changed successfully'), backgroundColor: Colors.green),
              );
            } else if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Failed to change password'), backgroundColor: Colors.red),
              );
            }
          },
          child: AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  decoration: const InputDecoration(labelText: 'Old Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm New Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (oldPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            if (newPasswordController.text != confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            if (newPasswordController.text.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            print('🔐 UI: Dispatching SettingsChangePassword event');
                            context.read<SettingsBloc>().add(
                                  SettingsChangePassword(
                                    oldPassword: oldPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  ),
                                );
                          },
                    child: state.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                        : const Text('Change Password'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear user data
              context.read<UserBloc>().add(const UserClearData());
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              // Navigate to login
              AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
