import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/core/AppStyles/app_styles.dart';
import 'package:banking_app/screens/auth/widgets/app_logo.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';
import 'package:banking_app/screens/nickname/bloc/nickname_bloc.dart';
import 'package:banking_app/screens/nickname/bloc/nickname_event.dart';
import 'package:banking_app/screens/nickname/bloc/nickname_state.dart';
import 'package:banking_app/screens/nickname/screens/existing_nickname_list_screen.dart';
import 'package:banking_app/screens/nickname/services/mock_api_with_local_stroage.dart';
import 'package:banking_app/screens/nickname/styles/style.dart';
import 'package:banking_app/screens/nickname/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateNicknameScreen extends StatefulWidget {
  const CreateNicknameScreen({super.key});

  @override
  State<CreateNicknameScreen> createState() => _CreateNicknameScreenState();
}

class _CreateNicknameScreenState extends State<CreateNicknameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _accountController.dispose();
    _nicknameController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => NicknameBloc(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF002D62)),
          ),
          centerTitle: true,
          title: Text('Add Favorites', style: titleTextStyle(context: context)),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: BlocBuilder<NicknameBloc, NicknameState>(
              builder: (ctx, state){
                final bloc = ctx.read<NicknameBloc>();
                 return Column(
                   children: [
                     Expanded(
                       child: SingleChildScrollView(
                         padding:
                         const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Container(
                               height: 225,
                               width: screenSize.width,
                               decoration: BoxDecoration(
                                 border: Border.all(
                                   color: AppStyles.textSecondary.withValues(alpha: .5),
                                 ),
                                 borderRadius:
                                 const BorderRadius.all(Radius.circular(10)),
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.all(20.0),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   spacing: 3,
                                   children: [
                                     Text('From :', style: subTitleStyle(context)),
                                     const CircleAvatar(
                                         radius: 30, child: AppLogo()),
                                     const SizedBox(height: 3),
                                     Text('Ms. San',
                                         style: normalTextStyle(ctx: context)),
                                     Text('234-1-56643-6',
                                         style: normalTextStyle(
                                             ctx: context, isBold: true)),
                                     Text('588,000 Ks',
                                         style: normalTextStyle(ctx: context)),
                                   ],
                                 ),
                               ),
                             ),
                             const SizedBox(height: 35),
                             Form(
                               key: _formKey,
                               child: Column(
                                 spacing: 30,
                                 children: [
                                   CustomTextField(
                                     controller: _accountController,
                                     label: 'Account no.',
                                     hint: 'Enter your Receiver account number',
                                     onChanged: (_) {
                                       bloc.add(
                                         NicknameChanged(
                                           _nicknameController.text,
                                           _accountController.text,
                                         ),
                                       );
                                     },
                                   ),
                                   CustomTextField(
                                     controller: _nicknameController,
                                     label: 'Nickname (if any)',
                                     hint: 'Enter your favorite nickname',
                                     onChanged: (_) {
                                       bloc.add(
                                         NicknameChanged(
                                           _nicknameController.text,
                                           _accountController.text,
                                         ),
                                       );
                                     },
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 50),
                           ],
                         ),
                       ),
                     ),

                     SafeArea(
                       minimum:
                       const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                       child: customElevatedButton(
                         text: 'Save',
                         onPressed: state.isButtonEnabled ? () async{
                          await LocalStorage.saveNickName(state.nickname, state.accountNumber);
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Successfully created !!!!'),
                               behavior: SnackBarBehavior.floating,
                               backgroundColor: Colors.green,
                               margin: const EdgeInsets.all(20), )
                           );
                           AppRoutes.navigateAndReplace(context, AppRoutes.nickNameList);
                         } : (){
                         //  Navigator.push(context, MaterialPageRoute(builder: (_) => ExistingNicknameListScreen()));
                         },
                         color: state.isButtonEnabled ? AppStyles.primary : Colors.grey,
                         textColor: AppStyles.surface,
                       ),
                     ),
                   ],
                 );
              },
            ),
          ),
        ),
      ),
    );
  }
}
