import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/auth/widgets/textfield.dart';
import 'package:banking_app/screens/nickname/screens/create_nickname_screen.dart';
import 'package:banking_app/screens/nickname/services/mock_api_with_local_stroage.dart';
import 'package:banking_app/screens/nickname/styles/style.dart';
import 'package:flutter/material.dart';

import '../../../core/AppStyles/app_styles.dart';

class ExistingNicknameListScreen extends StatefulWidget {
  const ExistingNicknameListScreen({super.key});

  @override
  State<ExistingNicknameListScreen> createState() =>
      _ExistingNicknameListScreenState();
}

class _ExistingNicknameListScreenState
    extends State<ExistingNicknameListScreen> {
  List<Map<String, String>> _favorites = [];
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final data = await LocalStorage.loadAllNickname();
    setState(() => _favorites = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed:
              () => AppRoutes.navigateAndReplace(
                context,
                AppRoutes.createNickname,
              ),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002D62)),
        ),
        centerTitle: true,
        title: Text('Favorites Nickname Lists', style: titleTextStyle(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _favorites.isEmpty
                    ? Center(child: Text('there are no any nicknames'))
                    : ListView.builder(
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 8,
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 5,
                                children: [
                                  Text(
                                    _favorites[index]['nickname']!,
                                    style: subTitleStyle(context),
                                  ),
                                  Text(
                                    _favorites[index]['accountNo']!,
                                    style: hintTextStyle(ctx: context),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  updateNickName(_favorites[index]);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: AppStyles.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          SafeArea(
            minimum: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
            child: customElevatedButton(
              text: 'Add New Favorite',
              onPressed: () {
                AppRoutes.navigateAndReplace(context, AppRoutes.createNickname);
              },
              color: AppStyles.primary,
              textColor: AppStyles.surface,
            ),
          ),
        ],
      ),
    );
  }

  // nickname update container
  updateNickName(Map<String, String> nickname) {
    // _accountController.text = nickname['accNo'];
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: 340,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                // padding: EdgeInsets.only(right: 10, top: 10),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.cancel_outlined, size: 30),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 15,
                  children: [
                    Center(
                      child: Text(
                        'Update Nickname',
                        style: subTitleStyle(context),
                      ),
                    ),
                    customTextField(
                      controller: _accountController,
                      enabled: false,
                      initialValue: nickname['accountNo'],
                    ),
                    customTextField(
                      controller: _nicknameController,
                      hintText: 'Enter new nickname',
                    ),
                  ],
                ),
              ),
              SafeArea(
                minimum: EdgeInsets.only(bottom: 10),
                child: customElevatedButton(
                  text: 'Submit',
                  color: AppStyles.primary,
                  textColor: AppStyles.surface,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
