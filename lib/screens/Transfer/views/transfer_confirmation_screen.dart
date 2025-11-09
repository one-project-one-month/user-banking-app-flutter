import 'package:banking_app/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/transfer_bloc.dart';
import '../controllers/transfer_event.dart';
import '../controllers/transfer_state.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';

class TransferConfirmationScreen extends StatefulWidget {
  final String recipientAccount;
  final String recipientName;

  const TransferConfirmationScreen({super.key, required this.recipientAccount, required this.recipientName});

  @override
  State<TransferConfirmationScreen> createState() => _TransferConfirmationScreenState();
}

class _TransferConfirmationScreenState extends State<TransferConfirmationScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF99A1AF), size: 20),
          ),
          title: const Text('Confirmation', style: TextStyle(fontSize: 20, fontFamily: 'DMS-B', color: Colors.black)),
          centerTitle: true,
        ),
        body: BlocConsumer<TransferBloc, TransferState>(
          listener: (context, state) {
            // Handle validation success - navigate to PIN
            if (state.isValidated) {
              AppRoutes.navigateTo(context, AppRoutes.pin);
            }

            // Handle errors
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'An error occurred'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, transferState) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final fromAccount = transferState.selectedFromAccount;
                final username = userState.user?.username ?? 'User';

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'From:',
                            style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: Color(0xFF6B7280)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fromAccount?.accountNumber ?? '',
                                style: const TextStyle(fontFamily: 'DMS-R', fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${fromAccount?.formattedBalance ?? '0'} Ks',
                                style: const TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: Color(0xFFFFB800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Logo placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Logo',
                            style: TextStyle(fontFamily: 'DMS-R', fontSize: 10, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Arrow down icon
                      const Icon(Icons.arrow_downward, color: Color(0xFFFFB800), size: 24),
                      const SizedBox(height: 20),
                      // To Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'To:',
                            style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: Color(0xFF6B7280)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.recipientName,
                                style: const TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.recipientAccount,
                                style: const TextStyle(fontFamily: 'DMS-R', fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Logo placeholder
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Logo',
                            style: TextStyle(fontFamily: 'DMS-R', fontSize: 10, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Divider
                      Container(height: 1, color: const Color(0xFFFFB800)),
                      const SizedBox(height: 30),
                      // Amount Field
                      const Text(
                        'Amount (Ks)',
                        style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: Colors.black),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter Amount',
                          hintStyle: TextStyle(fontSize: 13, fontFamily: 'DMS-R', color: Color(0xFFD1D5DC)),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB))),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0A3D62), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Note Field
                      const Text('Note', style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: Color(0xFF374151))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        maxLines: 4,
                        style: const TextStyle(fontFamily: 'DMS-R', fontSize: 14, color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Add your note here',
                          hintStyle: const TextStyle(fontSize: 13, fontFamily: 'DMS-R', color: Color(0xFFD1D5DC)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF0A3D62), width: 2),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Confirm Button
                      _buildConfirmButton(transferState),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfirmButton(TransferState state) {
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    final isValid = amount >= 1000;
    final recipient = state.recipient;
    final isLoading = state.isValidating;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isValid && !isLoading ? const Color(0xFF0A3D62) : const Color(0xFFD1D5DC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed:
            isValid && recipient != null && !isLoading
                ? () {
                  print('Confirm transfer');
                  print('Amount: ${amountController.text} Ks');
                  print('Note: ${noteController.text}');

                  // Parse recipient ID
                  final toAccountId = int.tryParse(recipient.id);
                  if (toAccountId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid recipient account'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // 🔥 Dispatch events using context.read<TransferBloc>().add()
                  // Step 1: Store transaction data
                  context.read<TransferBloc>().add(
                    TransferStoreTransactionData(amount: amount, note: noteController.text.trim()),
                  );

                  // Step 2: Validate transaction
                  context.read<TransferBloc>().add(
                    TransferValidateTransaction(
                      toAccountId: toAccountId,
                      amount: amount,
                      note: noteController.text.trim(),
                    ),
                  );

                  // Navigation will happen automatically via BlocListener
                }
                : null,
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                : Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'DMS-M',
                    fontSize: 16,
                    color: isValid ? Colors.white : const Color(0xFF99A1AF),
                  ),
                ),
      ),
    );
  }
}
