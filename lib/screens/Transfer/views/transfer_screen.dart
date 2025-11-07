import 'package:banking_app/Routes/app_routes.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/transfer_bloc.dart';
import '../controllers/transfer_event.dart';
import '../controllers/transfer_state.dart';
import '../models/transfer_models.dart';
import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  // Mock favorite users list
  final List<FavoriteUser> favoriteUsers = [
    FavoriteUser(nicknameId: '1', nickname: 'Mom', accountNumber: '00123456789', fullName: 'Mrs. Christine'),
    FavoriteUser(nicknameId: '2', nickname: 'Dad', accountNumber: '00198765432', fullName: 'Mr. John Doe'),
    FavoriteUser(nicknameId: '3', nickname: 'Bro', accountNumber: '00234567891', fullName: 'Mr. David'),
    FavoriteUser(nicknameId: '4', nickname: 'Sis', accountNumber: '00311223344', fullName: 'Ms. Julia'),
  ];

  FavoriteUser? selectedFavorite;
  final TextEditingController accountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool userInput = false;
  bool showAmountField = false;

  @override
  void initState() {
    super.initState();
    // Load from accounts when screen opens
    context.read<TransferBloc>().add(const TransferLoadFromAccounts());
  }

  @override
  void dispose() {
    accountController.dispose();
    fullNameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF99A1AF)),
          ),
          title: const Text('Transfer', style: TextStyle(fontSize: 24, fontFamily: 'DMS-B', color: Colors.black)),
          centerTitle: true,
        ),
        body: BlocConsumer<TransferBloc, TransferState>(
          listener: (context, transferState) {
            if (transferState.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(transferState.errorMessage ?? 'An error occurred'), backgroundColor: Colors.red),
              );
            }

            // When recipient is loaded, populate fields and show amount
            if (transferState.hasRecipient && transferState.recipient != null) {
              accountController.text = transferState.recipient!.accountNumber;
              fullNameController.text = transferState.recipient!.fullName;
              setState(() {
                showAmountField = true;
                amountController.text = '1000';
              });
            }
          },
          builder: (context, transferState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // From Account Section
                    _buildFromAccountSection(transferState),
                    const SizedBox(height: 20),

                    // Favorite Nickname Dropdown
                    const Text('Favorite nickname Lists', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18)),
                    _buildFavoriteDropdown(context, transferState),
                    const SizedBox(height: 25),

                    // To Section
                    _buildToSection(transferState),

                    // Account Number Field
                    _buildAccountNumberField(context, transferState),
                    const SizedBox(height: 25),

                    // Full Name Field
                    const Text('Full Name : ', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18)),
                    _buildFullNameField(),

                    // Amount Field (appears after verification)
                    if (showAmountField) ...[
                      const SizedBox(height: 25),
                      const Text('Amount : ', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18)),
                      _buildAmountField(transferState),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterDecoration: const BoxDecoration(border: Border(top: BorderSide.none)),
        persistentFooterButtons: [_buildContinueButton()],
      ),
    );
  }

  Widget _buildFromAccountSection(TransferState transferState) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final username = userState.user?.username ?? 'User';
        final fromAccount = transferState.selectedFromAccount;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD1D5DC), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('From :', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18)),
              const SizedBox(height: 10),
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DC)), shape: BoxShape.circle),
                child: const Center(
                  child: Text('Logo', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'DMS-R', fontSize: 12)),
                ),
              ),
              const SizedBox(height: 10),
              Text(username, style: const TextStyle(fontFamily: 'DMS-R', fontSize: 14)),
              const SizedBox(height: 5),

              // Show loading or account info
              if (transferState.isLoading)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading...', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 14)),
                    SizedBox(height: 5),
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                )
              else if (fromAccount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fromAccount.accountNumber, style: const TextStyle(fontFamily: 'DMS-SB', fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      '${fromAccount.formattedBalance} Ks',
                      style: const TextStyle(fontFamily: 'DMS-R', fontSize: 16),
                    ),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No account available',
                      style: TextStyle(fontFamily: 'DMS-R', fontSize: 14, color: Colors.red),
                    ),
                    SizedBox(height: 5),
                    Text('0 Ks', style: TextStyle(fontFamily: 'DMS-R', fontSize: 16)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteDropdown(BuildContext context, TransferState transferState) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFD1D5DC)))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<FavoriteUser>(
          hint: const Text(
            'Select nickname',
            style: TextStyle(fontSize: 12, fontFamily: 'DMS-R', color: Color(0xFF99A1AF)),
          ),
          iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down, size: 28, color: Color(0xFF99A1AF))),
          value: selectedFavorite,
          items:
              favoriteUsers.map((user) {
                return DropdownMenuItem<FavoriteUser>(value: user, child: Text(user.nickname));
              }).toList(),
          onChanged: (FavoriteUser? value) {
            if (value != null) {
              setState(() {
                selectedFavorite = value;
                userInput = false;
                showAmountField = true;
                amountController.text = '1000';
              });

              // Prepare transfer with API
              context.read<TransferBloc>().add(TransferPrepareByNickname(value.nicknameId));
            }
          },
        ),
      ),
    );
  }

  Widget _buildToSection(TransferState transferState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('To : ', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18)),
        if (selectedFavorite == null && !transferState.hasRecipient)
          GestureDetector(
            onTap: () {
              final account = accountController.text.trim();
              if (account.isNotEmpty) {
                setState(() {
                  userInput = true;
                  showAmountField = true;
                  amountController.text = '1000';
                });
                context.read<TransferBloc>().add(TransferPrepareByAccountNumber(account));
              }
            },
            child: Container(
              width: 54,
              height: 36,
              decoration: BoxDecoration(
                color: userInput ? const Color(0xFF0A3D62) : const Color(0xFFD1D5DC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(Icons.check, color: userInput ? Colors.white : Colors.grey.shade700)),
            ),
          )
        else
          const SizedBox(),
      ],
    );
  }

  Widget _buildAccountNumberField(BuildContext context, TransferState transferState) {
    final isEnabled = selectedFavorite == null && !transferState.hasRecipient;

    return TextField(
      keyboardType: TextInputType.number,
      controller: accountController,
      style: const TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: Colors.black),
      enabled: isEnabled,
      onChanged: (value) {
        setState(() {
          userInput = value.trim().isNotEmpty;
          if (value.trim().isEmpty) {
            fullNameController.clear();
            showAmountField = false;
            amountController.clear();
          }
        });
      },
      decoration: const InputDecoration(
        hintText: 'Account Number',
        hintStyle: TextStyle(fontSize: 12, fontFamily: 'DMS-R', color: Color(0xFF99A1AF)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextField(
      controller: fullNameController,
      enabled: false,
      style: const TextStyle(fontFamily: 'DMS-R', fontSize: 16, color: Colors.black),
      decoration: const InputDecoration(
        hintText: 'Full Name',
        hintStyle: TextStyle(fontSize: 12, fontFamily: 'DMS-R', color: Color(0xFF99A1AF)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
      ),
    );
  }

  Widget _buildAmountField(TransferState transferState) {
    return TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontFamily: 'DMS-SB', fontSize: 14, color: Colors.black),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        setState(() {});
      },
      decoration: const InputDecoration(
        hintText: 'Enter amount',
        hintStyle: TextStyle(fontSize: 12, fontFamily: 'DMS-R', color: Color(0xFF99A1AF)),
        suffixText: 'Ks',
        suffixStyle: TextStyle(fontFamily: 'DMS-M', fontSize: 14, color: Colors.black),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0A3D62), width: 2)),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isAccountValid = accountController.text.trim().isNotEmpty && fullNameController.text.trim().isNotEmpty;
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    final isAmountValid = amount > 0;
    final isValid = isAccountValid && isAmountValid && showAmountField;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isValid ? const Color(0xFF0A3D62) : const Color(0xFFD1D5DC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          onPressed:
              isValid
                  ? () {
                    print('Continue to next screen');
                    print('Account: ${accountController.text}');
                    print('Full Name: ${fullNameController.text}');
                    print('Amount: ${amountController.text} Ks');
                    AppRoutes.navigateTo(context, AppRoutes.pin);
                  }
                  : null,
          child: Text(
            'Continue',
            style: TextStyle(
              fontFamily: 'DMS-M',
              fontSize: 18,
              color: isValid ? const Color(0xFFE7ECEF) : const Color(0xFF99A1AF),
            ),
          ),
        ),
      ),
    );
  }
}
