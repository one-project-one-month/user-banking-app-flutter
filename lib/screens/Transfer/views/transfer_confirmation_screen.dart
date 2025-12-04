import 'package:banking_app/Routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/transfer_bloc.dart';
import '../controllers/transfer_event.dart';
import '../controllers/transfer_state.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';
import 'package:banking_app/responsive_utils.dart';

class TransferConfirmationScreen extends StatefulWidget {
  final String recipientAccount;
  final String recipientName;
  final int? prefilledAmount;
  final String? prefilledNote;
  final bool isQRPayment;

  const TransferConfirmationScreen({
    super.key,
    required this.recipientAccount,
    required this.recipientName,
    this.prefilledAmount,
    this.prefilledNote,
    this.isQRPayment = false,
  });

  @override
  State<TransferConfirmationScreen> createState() => _TransferConfirmationScreenState();
}

class _TransferConfirmationScreenState extends State<TransferConfirmationScreen> {
  late final TextEditingController amountController;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.prefilledAmount != null ? widget.prefilledAmount.toString() : '',
    );
    noteController = TextEditingController(text: widget.prefilledNote ?? '');
  }

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
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.iconTheme.color ?? Colors.grey,
              size: context.iconSize(20),
            ),
          ),
          title: Text(
            'Confirmation',
            style: TextStyle(
              fontSize: context.fontSize(20),
              fontFamily: 'DMS-B',
              color: theme.textTheme.titleLarge?.color ?? theme.colorScheme.onBackground,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<TransferBloc, TransferState>(
          listener: (context, state) {
            if (state.isValidated) {
              AppRoutes.navigateTo(context, AppRoutes.pin);
            }
            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, transferState) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final username = userState.user?.username ?? 'You';

                // KEY FIX: Use real balance from QR scan if available
                final fromAccountDetails = transferState.validationData?['fromAccountDetails'] as Map<String, dynamic>?;
                final qrFromBalance = fromAccountDetails?['balance'] as num?;
                final qrFromAccountNumber = fromAccountDetails?['accountNumber'] as String?;

                // Fallback to selected account (for normal transfers)
                final fallbackAccount = transferState.selectedFromAccount;
                final displayBalance = qrFromBalance?.toDouble() ?? fallbackAccount?.balance ?? 0.0;
                final displayAccountNumber = qrFromAccountNumber ?? fallbackAccount?.accountNumber ?? 'Unknown';

                return SingleChildScrollView(
                  padding: context.responsivePadding(all: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ResponsiveUtils.formWidth(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // From Section - Now shows correct balance from QR!
                        _buildAccountSection(
                          context: context,
                          label: 'From:',
                          name: username,
                          accountNumber: displayAccountNumber,
                          balance: '${displayBalance.toStringAsFixed(0)} Ks',
                          isSender: true,
                        ),
                        SizedBox(height: context.spacing(20)),

                        Center(
                          child: Icon(Icons.arrow_downward, size: context.iconSize(32), color: theme.colorScheme.primary),
                        ),
                        SizedBox(height: context.spacing(20)),

                        // To Section
                        _buildAccountSection(
                          context: context,
                          label: 'To:',
                          name: widget.recipientName,
                          accountNumber: widget.recipientAccount,
                          isSender: false,
                        ),
                        SizedBox(height: context.spacing(30)),

                        Divider(height: 1, thickness: 1, color: theme.colorScheme.primary),
                        SizedBox(height: context.spacing(30)),

                        // Amount Field
                        Text('Amount (Ks)', style: TextStyle(fontSize: context.fontSize(15), fontFamily: 'DMS-M', color: theme.colorScheme.onBackground)),
                        SizedBox(height: context.spacing(8)),
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          readOnly: widget.isQRPayment,
                          style: TextStyle(fontSize: context.fontSize(16), fontFamily: 'DMS-M'),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Enter Amount',
                            hintStyle: TextStyle(fontSize: context.fontSize(14), color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            filled: true,
                            fillColor: widget.isQRPayment
                                ? theme.colorScheme.surface.withOpacity(0.5)
                                : theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                            border: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                          ),
                        ),
                        SizedBox(height: context.spacing(30)),

                        // Note Field
                        Text('Note', style: TextStyle(fontSize: context.fontSize(15), fontFamily: 'DMS-M', color: theme.colorScheme.onBackground)),
                        SizedBox(height: context.spacing(8)),
                        TextField(
                          controller: noteController,
                          maxLines: 4,
                          readOnly: widget.isQRPayment,
                          style: TextStyle(fontSize: context.fontSize(14), fontFamily: 'DMS-R'),
                          decoration: InputDecoration(
                            hintText: 'Add your note here',
                            hintStyle: TextStyle(fontSize: context.fontSize(13), color: theme.colorScheme.onSurface.withOpacity(0.5)),
                            filled: true,
                            fillColor: widget.isQRPayment
                                ? theme.colorScheme.surface.withOpacity(0.5)
                                : theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface,
                            border: OutlineInputBorder(borderRadius: context.borderRadius(8), borderSide: BorderSide(color: theme.dividerColor)),
                            enabledBorder: OutlineInputBorder(borderRadius: context.borderRadius(8), borderSide: BorderSide(color: theme.dividerColor)),
                            focusedBorder: OutlineInputBorder(borderRadius: context.borderRadius(8), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                          ),
                        ),
                        SizedBox(height: context.spacing(40)),

                        // Confirm Button
                        _buildConfirmButton(context, transferState, theme),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + context.spacing(20)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountSection({
    required BuildContext context,
    required String label,
    required String name,
    required String accountNumber,
    String? balance,
    required bool isSender,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: context.fontSize(15), fontFamily: 'DMS-M', color: theme.colorScheme.onBackground.withOpacity(0.8))),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(name, style: TextStyle(fontSize: context.fontSize(16), fontFamily: 'DMS-SB', color: isSender ? theme.colorScheme.onBackground : Colors.black)),
              SizedBox(height: context.spacing(4)),
              Text(accountNumber, style: TextStyle(fontSize: context.fontSize(13), fontFamily: 'DMS-R', color: theme.colorScheme.onSurface.withOpacity(0.7))),
              if (balance != null) ...[
                SizedBox(height: context.spacing(6)),
                Text(balance, style: TextStyle(fontSize: context.fontSize(15), fontFamily: 'DMS-SB', color: theme.colorScheme.primary)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, TransferState state, ThemeData theme) {
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    final isValid = amount >= 1000;
    final isLoading = state.isValidating;
    final recipient = state.recipient;

    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.buttonHeight(context),
      child: ElevatedButton(
        onPressed: isValid && recipient != null && !isLoading
            ? () {
                final toAccountId = int.tryParse(recipient.id);
                if (toAccountId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid recipient account'), backgroundColor: Colors.red),
                  );
                  return;
                }

                context.read<TransferBloc>().add(TransferStoreTransactionData(amount: amount, note: noteController.text.trim()));
                context.read<TransferBloc>().add(TransferValidateTransaction(
                  toAccountId: toAccountId,
                  amount: amount,
                  note: noteController.text.trim(),
                ));
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid && !isLoading ? theme.colorScheme.primary : theme.disabledColor,
          foregroundColor: isValid ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: context.borderRadius(10)),
        ),
        child: isLoading
            ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.onPrimary))
            : Text('Confirm', style: TextStyle(fontSize: context.fontSize(17), fontFamily: 'DMS-SB')),
      ),
    );
  }
}