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
import 'controllers/settings_bloc.dart';
import 'controllers/settings_event.dart';
import 'controllers/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSaveReceipt = false;
  bool _notifications = true;
  bool _biometricAuth = false;
  String _language = 'English';
  String _currency = 'MMK (Kyat)';

  @override
  void initState() {
    super.initState();
    // Initialize settings from saved preferences if needed
  }

  void _showLogoutDialog() {
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

                  // Navigate to login and clear navigation stack
                  Navigator.of(context).pop(); // Close dialog
                  AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
            ],
          ),
    );
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
                      setState(() {
                        _language = value!;
                      });
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
                      setState(() {
                        _language = value!;
                      });
                      Navigator.of(context).pop();
                    },
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
            _animatedTile(fade: _nickFade, slide: _nickSlide, title: 'Nickname', onTap: () {
              AppRoutes.navigateTo(context, AppRoutes.nickname);
            }),

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
              ],
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
                      setState(() {
                        _currency = value!;
                      });
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
                      setState(() {
                        _currency = value!;
                      });
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
                      setState(() {
                        _currency = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => SettingsBloc())],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A3D62),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: BlocListener<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state.isSuccess && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: const Color(0xFF16A34A),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state.hasError && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1),

                // Account Settings Section
                _buildSectionHeader('Account'),
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile Information',
                  subtitle: 'View and edit your profile',
                  onTap: () {
                    // Navigate to profile edit screen
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Profile Information - Coming soon')));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title: 'Change PIN',
                  subtitle: 'Update your transaction PIN',
                  onTap: () {
                    // Navigate to change PIN screen
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Change PIN - Coming soon')));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () {
                    // Navigate to change password screen
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Change Password - Coming soon')));
                  },
                ),

                const Divider(height: 1, thickness: 1),

                // Preferences Section
                _buildSectionHeader('Preferences'),

                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    return _buildSwitchTile(
                      icon: Icons.receipt_long,
                      title: 'Auto-Save Receipts',
                      subtitle: 'Automatically save transaction receipts',
                      value: state.autoSaveReceipt,
                      onChanged: (value) {
                        setState(() {
                          _autoSaveReceipt = value;
                        });
                        // Call API to update preference
                        context.read<SettingsBloc>().add(SettingsAutoSaveReceipt(value));
                      },
                    );
                  },
                ),

                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Enable push notifications',
                  value: _notifications,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Notifications ${value ? 'enabled' : 'disabled'}')));
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Use fingerprint or face ID',
                  value: _biometricAuth,
                  onChanged: (value) {
                    setState(() {
                      _biometricAuth = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Biometric authentication ${value ? 'enabled' : 'disabled'}')),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: _language,
                  onTap: _showLanguageDialog,
                  showTrailing: true,
                ),
                _buildSettingsTile(
                  icon: Icons.attach_money,
                  title: 'Currency',
                  subtitle: _currency,
                  onTap: _showCurrencyDialog,
                  showTrailing: true,
                ),

                const Divider(height: 1, thickness: 1),

                // Support Section
                _buildSectionHeader('Support'),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with your account',
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Help & Support - Coming soon')));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Banking App',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.account_balance, size: 48, color: Color(0xFF0A3D62)),
                      children: [const Text('A secure and convenient banking application.')],
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Privacy Policy - Coming soon')));
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Read terms and conditions',
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Terms & Conditions - Coming soon')));
                  },
                ),

                const Divider(height: 1, thickness: 1),

                // Logout Section
                _buildSectionHeader('Account Actions'),
                _buildSettingsTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: _showLogoutDialog,
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                ),

                const SizedBox(height: 40),

                // Version Info
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Banking App',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state.user;
        final username = user?.username ?? 'User';
        final email = user?.email ?? 'user@example.com';
        final balance = user?.formattedBalance ?? '0';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A3D62), Color(0xFF1888D9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 48, color: const Color(0xFF0A3D62)),
              ),
              const SizedBox(height: 12),

              // Username
              Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),

              // Email
              Text(email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
              const SizedBox(height: 12),

              // Balance Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Balance: $balance MMK',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showTrailing = true,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF0A3D62)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? const Color(0xFF0A3D62), size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor ?? Colors.black87),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      trailing: showTrailing ? Icon(Icons.chevron_right, color: Colors.grey[400]) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF0A3D62).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF0A3D62), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF0A3D62)),
    );
  }
}
