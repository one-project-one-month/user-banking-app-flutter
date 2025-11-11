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
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color ?? Colors.grey, size: 20),
          ),
          title: Text(
            'Confirmation',
            style: TextStyle(fontSize: 20, fontFamily: 'DMS-B', color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onBackground),
          ),
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
                          Text(
                            'From:',
                            style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: theme.colorScheme.onBackground.withOpacity(0.75)),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                username,
                                style: TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: theme.colorScheme.onBackground),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fromAccount?.accountNumber ?? '',
                                style: TextStyle(fontFamily: 'DMS-R', fontSize: 13, color: theme.colorScheme.onBackground.withOpacity(0.75)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${fromAccount?.formattedBalance ?? '0'} Ks',
                                style: TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: theme.colorScheme.primary),
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
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Logo',
                            style: TextStyle(fontFamily: 'DMS-R', fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Arrow down icon
                      Icon(Icons.arrow_downward, color: theme.colorScheme.primary, size: 24),
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
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Logo',
                            style: TextStyle(fontFamily: 'DMS-R', fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Divider
                      Container(height: 1, color: theme.colorScheme.primary),
                      const SizedBox(height: 30),
                      // Amount Field
                      Text(
                        'Amount (Ks)',
                        style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: theme.colorScheme.onBackground),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: theme.colorScheme.onBackground),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Amount',
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                          hintStyle: TextStyle(fontSize: 13, fontFamily: 'DMS-R', color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
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
                        style: TextStyle(fontFamily: 'DMS-R', fontSize: 14, color: theme.colorScheme.onBackground),
                        decoration: InputDecoration(
                          hintText: 'Add your note here',
                          hintStyle: TextStyle(fontSize: 13, fontFamily: 'DMS-R', color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
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
    final theme = Theme.of(context);
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    final isValid = amount >= 1000;
    final recipient = state.recipient;
    final isLoading = state.isValidating;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isValid && !isLoading ? theme.colorScheme.primary : theme.disabledColor,
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
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                )
                : Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'DMS-M',
                    fontSize: 16,
                    color: isValid ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
      ),
    );
  }
}
