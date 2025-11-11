import 'package:banking_app/AppStyles/Style.dart';
import 'package:banking_app/screens/Transfer/views/transfer_confirmation_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
  // This will hold nicknames fetched from API
  List<FavoriteUser> favoriteUsers = [];
  bool isLoadingNicknames = false;

  FavoriteUser? selectedFavorite;
  final TextEditingController accountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  bool userInput = false;
  bool isValidatingAccount = false;

  @override
  void initState() {
    super.initState();
    // Load from accounts when screen opens
    context.read<TransferBloc>().add(const TransferClearRecipient());
    context.read<TransferBloc>().add(const TransferLoadFromAccounts());
    // Load nicknames from API
    _loadNicknames();
  }

  @override
  void dispose() {
    accountController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadNicknames() async {
    setState(() {
      isLoadingNicknames = true;
    });

    try {
      final transferBloc = context.read<TransferBloc>();
      final nicknames = await transferBloc.api.fetchNicknames((await transferBloc.cache.getToken())!.accessToken);

      setState(() {
        favoriteUsers = nicknames;
        isLoadingNicknames = false;
      });
    } catch (e) {
      print('❌ Failed to load nicknames: $e');
      setState(() {
        isLoadingNicknames = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load favorites: $e'), backgroundColor: Colors.orange));
      }
    }
  }

  void _validateAccount() {
    final account = accountController.text.trim();
    if (account.isNotEmpty) {
      setState(() {
        userInput = true;
        isValidatingAccount = true;
      });
      // Call prepare endpoint to validate and get recipient details
      context.read<TransferBloc>().add(TransferPrepareByAccountNumber(account));
    }
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
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color ?? Colors.black),
          ),
          title: Text(
            'Transfer',
            style: GoogleFonts.inter(
              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          //tyle: TextStyle(fontSize: 24, fontFamily: 'DMS-B', color: Colors.black)),
          centerTitle: true,
          actions: [
            // Refresh nicknames button
            IconButton(
              icon: Icon(Icons.refresh, color: theme.iconTheme.color ?? Colors.black),
              onPressed: isLoadingNicknames ? null : _loadNicknames,
            ),
          ],
        ),
        body: BlocConsumer<TransferBloc, TransferState>(
          listener: (context, transferState) {
            if (transferState.hasError) {
              setState(() {
                isValidatingAccount = false;
                fullNameController.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(transferState.errorMessage ?? 'An error occurred'), backgroundColor: Colors.red),
              );
            }

            // When recipient is loaded from account number validation
            if (transferState.hasRecipient && transferState.recipient != null && isValidatingAccount) {
              setState(() {
                isValidatingAccount = false;
              });
              accountController.text = transferState.recipient!.accountNumber;
              fullNameController.text = transferState.recipient!.fullName;
            }

            // When recipient is loaded from nickname selection
            if (transferState.hasRecipient && transferState.recipient != null && selectedFavorite != null) {
              accountController.text = transferState.recipient!.accountNumber;
              fullNameController.text = transferState.recipient!.fullName;
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Favorite nickname Lists', style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18)),
                        ),
                        if (isLoadingNicknames)
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
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
          hint: Text(
            favoriteUsers.isEmpty ? (isLoadingNicknames ? 'Loading...' : 'No favorites available') : 'Select nickname',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'DMS-R',
              color: favoriteUsers.isEmpty ? Colors.grey : const Color(0xFF99A1AF),
            ),
          ),
          iconStyleData: const IconStyleData(icon: Icon(Icons.keyboard_arrow_down, size: 28, color: Color(0xFF99A1AF))),
          value: selectedFavorite,
          items:
              favoriteUsers.isEmpty
                  ? null
                  : favoriteUsers.map((user) {
                    return DropdownMenuItem<FavoriteUser>(value: user, child: Text(user.nickname));
                  }).toList(),
          onChanged:
              favoriteUsers.isEmpty || transferState.isLoading
                  ? null
                  : (FavoriteUser? value) {
                    if (value != null) {
                      setState(() {
                        selectedFavorite = value;
                        userInput = false;
                        accountController.clear();
                        fullNameController.clear();
                      });
                      // Prepare transfer with API using nicknameId
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
            onTap: isValidatingAccount ? null : _validateAccount,
            child: Container(
              width: 54,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isValidatingAccount ? Colors.grey : (userInput ? const Color(0xFF0A3D62) : const Color(0xFFD1D5DC)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child:
                    isValidatingAccount
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                        : Icon(Icons.check, color: userInput ? Colors.white : Colors.grey.shade700),
              ),
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
      style: TextStyle(
        fontFamily: 'DMS-SB',
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      ),
      enabled: isEnabled,
      onChanged: (value) {
        setState(() {
          userInput = value.trim().isNotEmpty;
          if (value.trim().isEmpty) {
            fullNameController.clear();
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
      style: TextStyle(
        fontFamily: 'DMS-SB',
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      ),

      decoration: const InputDecoration(
        hintText: 'Full Name',
        hintStyle: TextStyle(fontSize: 12, fontFamily: 'DMS-R', color: Color(0xFF99A1AF)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
        disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD1D5DC))),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isValid = accountController.text.trim().isNotEmpty && fullNameController.text.trim().isNotEmpty;

    return BlocBuilder<TransferBloc, TransferState>(
      builder: (context, transferState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isValid ? AppColors.deepNavy : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed:
                  isValid // ✅ FIXED - button enabled when form IS valid
                      ? () {
                        print('✅ Continue button pressed');
                        print('   Account: ${accountController.text}');
                        print('   Name: ${fullNameController.text}');

                        // Navigate to confirmation screen with recipient data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TransferConfirmationScreen(
                                  recipientAccount: accountController.text,
                                  recipientName: fullNameController.text,
                                ),
                          ),
                        );
                      }
                      : null,
              child: Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'DMS-M',
                  fontSize: 18,
                  color: isValid ? Theme.of(context).colorScheme.onPrimary : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
