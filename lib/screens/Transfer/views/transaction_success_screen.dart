import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/Settings/controllers/settings_bloc.dart';
import 'package:banking_app/screens/Settings/controllers/settings_event.dart';
import 'package:banking_app/screens/Settings/controllers/settings_state.dart';
import 'widgets/transaction_info_row.dart';
import 'widgets/account_info_card.dart';
import 'widgets/nickname_bottom_sheet.dart';

class TransactionSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionData;

  const TransactionSuccessScreen({super.key, this.transactionData});

  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  String? _nickname;

  void _showNicknameBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => NicknameBottomSheet(
            onSave: (nickname) {
              setState(() {
                _nickname = nickname;
              });
            },
          ),
    );
  }

  void _saveReceipt() {
    context.read<SettingsBloc>().add(const SettingsAutoSaveReceipt(true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Receipt saved successfully!'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to save receipt'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    // Default transaction data if none provided
    final data =
        widget.transactionData ??
        {
          'fromName': 'Ms. San',
          'fromAccount': '234-1-56643-6',
          'toName': 'Mr. Jhon',
          'toAccount': '671-2-67452-2',
          'amount': '588,000',
          'currency': 'Ks',
          'note': 'Testing',
        };

    return Scaffold(
      backgroundColor: const Color(0xFF002D62),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002D62),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(''),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main transaction card - scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(CommonSize.s20(context)),
                child: Card(
                  elevation: 4,
                  color:
                      Colors
                          .grey[50], // Same light off-white as contact info cards
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CommonSize.s16(context),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(CommonSize.s16(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Text(
                            'Transfer Successful',
                            style: TextStyle(
                              color: const Color(0xFF002D62),
                              fontSize: CommonSize.s18(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: CommonSize.s16(context)),

                        // From Section
                        Text(
                          'From:',
                          style: TextStyle(
                            color: const Color(0xFF002D62),
                            fontSize: CommonSize.s14(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: CommonSize.s8(context)),

                        AccountInfoCard(
                          name: data['fromName'] ?? 'Ms. San',
                          accountNumber: data['fromAccount'] ?? '234-1-56643-6',
                          amount:
                              '${data['amount'] ?? '588,000'} ${data['currency'] ?? 'Ks'}',
                          amountColor: const Color(0xFFFFA726),
                        ),

                        SizedBox(height: CommonSize.s20(context)),

                        // Direction Arrow
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(CommonSize.s6(context)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFFFA726).withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.arrow_downward,
                              color: const Color(0xFFFFA726),
                              size: CommonSize.s20(context),
                            ),
                          ),
                        ),

                        SizedBox(height: CommonSize.s20(context)),

                        // To Section
                        Text(
                          'To:',
                          style: TextStyle(
                            color: const Color(0xFF002D62),
                            fontSize: CommonSize.s14(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: CommonSize.s8(context)),

                        AccountInfoCard(
                          name: data['toName'] ?? 'Mr. Jhon',
                          accountNumber: data['toAccount'] ?? '671-2-67452-2',
                        ),

                        SizedBox(height: CommonSize.s16(context)),

                        // Divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFFFA726),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: CommonSize.s12(context)),

                        // Amount Section
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: CommonSize.s8(context),
                            horizontal: CommonSize.s12(context),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(
                              CommonSize.s6(context),
                            ),
                          ),
                          child: TransactionInfoRow(
                            label: 'Amount (Ks)',
                            value:
                                '${data['amount'] ?? '588,000'} ${data['currency'] ?? 'Ks'}',
                            valueFontWeight: FontWeight.bold,
                            valueFontSize: CommonSize.s16(context),
                            labelFontSize: CommonSize.s14(context),
                            labelColor: const Color(0xFF002D62),
                            valueColor: const Color(0xFF002D62),
                          ),
                        ),

                        SizedBox(height: CommonSize.s8(context)),

                        // Transfer Fee
                        TransactionInfoRow(
                          label: 'Transfer fee',
                          value: '0 ${data['currency'] ?? 'Ks'}',
                          labelColor: const Color(0xFF6B7280),
                          valueColor: const Color(0xFF6B7280),
                          labelFontSize: CommonSize.s12(context),
                          valueFontSize: CommonSize.s12(context),
                        ),

                        SizedBox(height: CommonSize.s8(context)),

                        // Note
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: CommonSize.s8(context),
                            horizontal: CommonSize.s12(context),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFA726).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              CommonSize.s6(context),
                            ),
                          ),
                          child: TransactionInfoRow(
                            label: 'Note',
                            value: data['note'] ?? 'Testing',
                            labelColor: const Color(0xFFFFA726),
                            valueColor: const Color(0xFFFFA726),
                            labelFontSize: CommonSize.s12(context),
                            valueFontSize: CommonSize.s12(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Set up nickname button - centered in remaining space
          Container(
            height: 135, // Fixed height for the button area
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showNicknameBottomSheet,
                    child: Container(
                      width: CommonSize.s48(context),
                      height: CommonSize.s48(context),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0A3D62),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  SizedBox(height: CommonSize.s6(context)),

                  Text(
                    'Set up nickname',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: CommonSize.s12(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (_nickname != null) ...[
                    SizedBox(height: CommonSize.s4(context)),
                    Text(
                      'Nickname: $_nickname',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: CommonSize.s12(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: CommonSize.s40(context), // Increased horizontal padding
          vertical: CommonSize.s20(context),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: customElevatedButton(
          onPressed: _saveReceipt,
          text: 'Save Receipt',
          color: const Color(0xFF0A3D62),
          textColor: Colors.white,
          borderRadius: BorderRadius.circular(CommonSize.s12(context)),
          height: CommonSize.s48(context),
          width: double.infinity,
          fontSize: CommonSize.s18(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
