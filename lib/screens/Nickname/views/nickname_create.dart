import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';

class NicknameCreateScreen extends StatefulWidget {
  const NicknameCreateScreen({super.key});

  @override
  State<NicknameCreateScreen> createState() => _NicknameCreateScreenState();
}

class _NicknameCreateScreenState extends State<NicknameCreateScreen> {
  final _accountController = TextEditingController();
  final _nickController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_validate);
    _nickController.addListener(_validate);
  }

  @override
  void dispose() {
    _accountController.removeListener(_validate);
    _nickController.removeListener(_validate);
    _accountController.dispose();
    _nickController.dispose();
    super.dispose();
  }

  void _validate() {
    final acc = _accountController.text.trim();
    final nick = _nickController.text.trim();
    // Just check if both fields have content
    final can = acc.isNotEmpty && nick.isNotEmpty;
    if (can != _canSave) setState(() => _canSave = can);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final accountInput = _accountController.text.trim();
    final nicknameInput = _nickController.text.trim();

    print('📝 Creating nickname with:');
    print('   account ID: $accountInput');
    print('   nickname: $nicknameInput');

    final payload = {
      'account': accountInput, // This is the account ID (can be numeric like "1" or string like "ADM-0001")
      'nickname': nicknameInput,
    };

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text(
          'Add Favorite',
          style: GoogleFonts.inter(
            color: theme.textTheme.titleLarge?.color ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: const Color(0xFF3366FF).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xFF3366FF)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add frequently used accounts to your favorites for quick access',
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account ID
                  Text(
                    'Account ID',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  customTextField(
                    cursorColor: theme.textSelectionTheme.cursorColor,
                    controller: _accountController,
                    hintText: 'Enter account ID (e.g., 1 or ADM-0001)',
                    borderColor: Colors.grey.shade400,
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50,
                    borderRadius: 8,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter account ID';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Nickname - NO LENGTH RESTRICTIONS
                  Text(
                    'Nickname',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  customTextField(
                    cursorColor: theme.textSelectionTheme.cursorColor,
                    controller: _nickController,
                    hintText: 'Enter a friendly nickname',
                    borderColor: Colors.grey.shade400,
                    filled: true,
                    fillColor: theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50,
                    borderRadius: 8,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a nickname';
                      }
                      // NO minimum length requirement
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSave ? _onSave : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSave ? const Color(0xFF3366FF) : Colors.grey.shade300,
                        foregroundColor: _canSave ? Colors.white : Colors.black45,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: _canSave ? 2 : 0,
                      ),
                      child: Text('Save Favorite', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
