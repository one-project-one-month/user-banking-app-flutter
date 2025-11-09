import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/screens/Nickname/models/nickname.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';

class NicknameEditScreen extends StatefulWidget {
  final NicknameOption option;
  const NicknameEditScreen({super.key, required this.option});

  @override
  State<NicknameEditScreen> createState() => _NicknameEditScreenState();
}

class _NicknameEditScreenState extends State<NicknameEditScreen> {
  late final TextEditingController _nickController;
  final _formKey = GlobalKey<FormState>();
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _nickController = TextEditingController(text: widget.option.nickname);
    _nickController.addListener(_validate);
    _validate();
  }

  @override
  void dispose() {
    _nickController.removeListener(_validate);
    _nickController.dispose();
    super.dispose();
  }

  void _validate() {
    final nick = _nickController.text.trim();
    final can = nick.isNotEmpty && nick != widget.option.nickname;
    if (can != _canSave) setState(() => _canSave = can);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    // IMPORTANT: Send the ID, not the account number
    // The API expects the toAccountDetail.id (which is a number like "1")
    // NOT the accountNumber (which is "ADM-0001")
    final payload = {
      'id': widget.option.id,
      'toAccountId': widget.option.toaccountDetail.id, // Use the ID from the detail
      'nickname': _nickController.text.trim(),
    };

    print('📝 Edit payload: $payload');

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
          'Edit Favorite',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.amber.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Update the nickname for this account',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Account Number (Read-only)
              Text(
                'Account Number',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  widget.option.toaccountDetail.accountNumber,
                  style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
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
                hintText: 'Enter nickname',
                borderColor: Colors.grey.shade400,
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor ?? Colors.grey.shade50,
                borderRadius: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nickname';
                  }
                  // NO minimum length requirement - accept any non-empty nickname
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
                  child: Text('Update Favorite', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
