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
    final can = nick.isNotEmpty;
    if (can != _canSave) setState(() => _canSave = can);
  }

  void _onSave() {
    final payload = {
      'id': widget.option.id,
      'toaccountId': widget.option.toaccountDetail.id.isNotEmpty
          ? widget.option.toaccountDetail.id
          : widget.option.toaccountDetail.accountNumber,
      'nickname': _nickController.text.trim(),
    };
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text('Edit Favorite', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account no.', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Text(widget.option.toaccountDetail.accountNumber, style: GoogleFonts.inter()),
            const SizedBox(height: 20),
            Text('Nickname', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            customTextField(controller: _nickController, hintText: 'Enter nickname', borderColor: Colors.grey, borderRadius: 8,cursorColor: theme.textSelectionTheme.cursorColor,
                 ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave ? _onSave : null,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Save', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
