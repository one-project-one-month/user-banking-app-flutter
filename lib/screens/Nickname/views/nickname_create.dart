import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';

/// Screen to add a favorite by account number + optional nickname.
/// Replaces previous complex implementation with a focused form driven by user data.
class NicknameCreateScreen extends StatefulWidget {
  const NicknameCreateScreen({super.key});

  @override
  State<NicknameCreateScreen> createState() => _NicknameCreateScreenState();
}

class _NicknameCreateScreenState extends State<NicknameCreateScreen> {
  final _accountController = TextEditingController();
  final _nickController = TextEditingController();
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
    final validAcc = acc.isNotEmpty && acc.length >= 6; // basic sanity
    final can = validAcc && nick.isNotEmpty;
    if (can != _canSave) setState(() => _canSave = can);
  }

  void _onSave() {
    final payload = {
      'account': _accountController.text.trim(),
      'nickname': _nickController.text.trim(),
    };
    // Return the created favorite to the caller.
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
        title: Text('Add Favorites', style: GoogleFonts.inter(color: theme.textTheme.titleLarge?.color ?? Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final user = userState.user;
            final fullName = user?.username ?? 'Ms. Sam';
            // Build a simple recent-like card from user info (no dedicated recentTransactions in UserState)
            final preAccount = user?.selectedAccountDetails?.accountNumber;
            final recent = <String, String?>{
              'fromType': 'From',
              'appLogoUrl': null,
              'fromName': fullName,
              'date': DateTime.now().toLocal().toString().split(' ').first,
              'amount': user?.selectedAccountDetails?.balance != null ? '${user!.selectedAccountDetails!.balance} Ks' : null,
            };
            if (preAccount != null && _accountController.text.isEmpty) {
              _accountController.text = preAccount;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Recent transaction card
                // show recent-like card using user data
                _RecentTransactionCard(
                  fromLabel: recent['fromType'] ?? 'From',
                  logo: recent['appLogoUrl'],
                  username: recent['fromName'] ?? fullName,
                  date: recent['date'] ?? '',
                  amount: recent['amount'] ?? '',
                ),
                const SizedBox(height: 20),

                Text('Account no.', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                customTextField(
                  cursorColor: theme.textSelectionTheme.cursorColor,
                 
                  controller: _accountController,
                  hintText: 'Enter your Receiver account number',
                  keyboardType: TextInputType.number,
                  borderColor: Colors.grey,
                  filled: true,
                  borderRadius: 8,
                ),

                const SizedBox(height: 20),
                Text('Nickname(if any)', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                customTextField(
                  cursorColor: theme.textSelectionTheme.cursorColor,
                 
                  controller: _nickController,
                  hintText: 'Enter your favorite nickname',
                  borderColor: Colors.grey,
                  borderRadius: 8,
                ),

                const SizedBox(height: 32),
                // Save button full width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSave ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSave ? const Color(0xFF3366FF) : Colors.grey.shade300,
                      foregroundColor: _canSave ? Colors.white : Colors.black45,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Save', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  final String fromLabel;
  final String? logo;
  final String username;
  final String date;
  final String amount;

  const _RecentTransactionCard({required this.fromLabel, this.logo, required this.username, required this.date, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // logo
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              child: logo == null ? Text(username.isNotEmpty ? username[0] : 'U') : null,
            ),
            const SizedBox(width: 12),
            // details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fromLabel, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(username, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(date, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // amount
            Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

}