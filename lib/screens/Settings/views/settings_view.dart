import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/settings_bloc.dart';
import '../controllers/settings_event.dart';
import '../controllers/settings_state.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  // primary theme blue used in controls
  static const Color kBlue = Color(0xFF3366FF);

  @override
  Widget build(BuildContext context) {
    // Use the SettingsBloc provided at the app root so theme changes propagate
    // in real-time. Do not create a new SettingsBloc here.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        centerTitle: true,
  title: Text('Settings', style: GoogleFonts.inter(color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color ?? Colors.black),
      ),
      body: const SafeArea(child: _SettingsBody()),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _ProfileCard(),
          const SizedBox(height: 20),
          _TogglesCard(),
          const SizedBox(height: 20),
          _ButtonsList(),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.select((SettingsBloc bloc) => bloc.state.user);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0,2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            child: Text(user.name.isNotEmpty ? user.name.split(' ').map((e) => e.isNotEmpty?e[0]:'').take(2).join() : 'S',
                style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.titleLarge?.color)),
                const SizedBox(height: 4),
                Text(user.phone, style: GoogleFonts.inter(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
        ],
      ),
    );
  }
}

class _TogglesCard extends StatelessWidget {
  const _TogglesCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dark Mode', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Switch(
                    value: state.darkMode,
                    activeColor: SettingsView.kBlue,
                    onChanged: (v) => context.read<SettingsBloc>().add(ToggleDarkMode(v)),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Auto Save E-Script', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Switch(
                    value: state.autoSave,
                    activeColor: SettingsView.kBlue,
                    onChanged: (v) => context.read<SettingsBloc>().add(ToggleAutoSave(v)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ButtonsList extends StatelessWidget {
  const _ButtonsList({Key? key}) : super(key: key);

  // style helper intentionally left inline in build to keep code simple

  @override
  Widget build(BuildContext context) {
        Widget buildButton(Widget child, {VoidCallback? onTap}) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: SettingsView.kBlue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          onPressed: onTap ?? () {},
          child: child,
        ),
      );
    }

  // theme can be read if needed: final theme = Theme.of(context);

    return Column(
      children: [
        buildButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Change Mobile Pin', style: GoogleFonts.inter(fontSize: 15, color: Colors.black)), const SizedBox.shrink()],
        )),
        const SizedBox(height: 12),
        buildButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Select Account', style: GoogleFonts.inter(fontSize: 15, color: Colors.black)), Icon(Icons.arrow_drop_down, color: SettingsView.kBlue)],
        )),
        const SizedBox(height: 12),
        buildButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Change Transaction Pin', style: GoogleFonts.inter(fontSize: 15, color: Colors.black)), const SizedBox.shrink()],
        )),
        const SizedBox(height: 12),
        buildButton(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Nickname', style: GoogleFonts.inter(fontSize: 15, color: Colors.black)), const SizedBox.shrink()],
        )),
        const SizedBox(height: 16),
        // Logout button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
            onPressed: () => context.read<SettingsBloc>().add(LogoutPressed()),
            child: Row(
              children: [
                const Icon(Icons.logout, color: Colors.red),
                const SizedBox(width: 12),
                Text('Log Out', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
