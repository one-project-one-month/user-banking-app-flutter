import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final List<String> items = ['Item1', 'Item2', 'Item3', 'Item4'];
  final List<User> favoriteUsers = [
    User(
      nickname: 'Mom',
      accountNumber: '00123456789',
      fullName: 'Mrs. Christine',
    ),
    User(
      nickname: 'Dad',
      accountNumber: '00198765432',
      fullName: 'Mr. John Doe',
    ),
    User(nickname: 'Bro', accountNumber: '00234567891', fullName: 'Mr. David'),
    User(nickname: 'Sis', accountNumber: '00311223344', fullName: 'Ms. Julia'),
  ];
  User? selectedUser;
  final TextEditingController accountController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  bool userInput = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF99A1AF)),
          ),
          title: Text(
            'Transfer',
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'DMS-B',
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFD1D5DC), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From :',
                        style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 41,
                        height: 41,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFD1D5DC)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'Logo',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'DMS-R', fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ms. San',
                        style: TextStyle(fontFamily: 'DMS-R', fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '234-1-56643-6',
                        style: TextStyle(fontFamily: 'DMS-SB', fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '588,000 Ks',
                        style: TextStyle(fontFamily: 'DMS-R', fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Favorite nickname Lists',
                  style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                      bottom: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<User>(
                      hint: Text(
                        'Select nickname',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'DMS-R',
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 28,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                      underline: Container(height: 2, color: Color(0xFFD1D5DC)),
                      value: selectedUser,
                      items:
                          favoriteUsers.map((user) {
                            return DropdownMenuItem<User>(
                              value: user,
                              child: Text(user.nickname),
                            );
                          }).toList(),
                      onChanged: (User? value) {
                        setState(() {
                          selectedUser = value;
                          accountController.text = value?.accountNumber ?? '';
                          fullNameController.text = value?.fullName ?? '';
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'To : ',
                      style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18),
                    ),
                    if (selectedUser == null) ...[
                      GestureDetector(
                        onTap: () {
                          //TODO: to add a condition when binding with backend
                        },
                        child: Container(
                          width: 54,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                userInput
                                    ? Color(0xFF0A3D62)
                                    : Color(0xFFD1D5DC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            // white
                            child: Icon(
                              Icons.check,
                              color:
                                  userInput
                                      ? Colors.white
                                      : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(),
                    ],
                  ],
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: accountController,
                  style: TextStyle(
                    fontFamily: 'DMS-SB',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  enabled: selectedUser == null ? true : false,
                  onChanged:
                      (value) => {
                        if (value.trim().isNotEmpty)
                          {
                            setState(() {
                              userInput = true;
                            }),
                          }
                        else
                          {
                            setState(() {
                              userInput = false;
                            }),
                          },
                      },
                  decoration: InputDecoration(
                    hint: Text(
                      'Account Number',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'DMS-R',
                        color: Color(0xFF99A1AF),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Full Name : ',
                  style: TextStyle(fontFamily: 'DMS-SB', fontSize: 18),
                ),
                TextField(
                  controller: fullNameController,
                  enabled: false,
                  style: TextStyle(
                    fontFamily: 'DMS-R',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hint: Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'DMS-R',
                        color: Color(0xFF99A1AF),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DC)),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterDecoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
        ),
        persistentFooterButtons: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    accountController.text.trim().isEmpty ||
                            fullNameController.text.trim().isEmpty
                        ? Color(0xFFD1D5DC)
                        : Color(0xFF0A3D62),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed:
                    accountController.text.trim().isEmpty ||
                            fullNameController.text.trim().isEmpty
                        ? null
                        : () {},
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'DMS-M',
                    fontSize: 18,
                    color:
                        accountController.text.trim().isEmpty ||
                                fullNameController.text.trim().isEmpty
                            ? Color(0xFF99A1AF)
                            : Color(0xFFE7ECEF),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// mockup favorite user
// will discard later
class User {
  final String nickname;
  final String accountNumber;
  final String fullName;

  User({
    required this.nickname,
    required this.accountNumber,
    required this.fullName,
  });
}
