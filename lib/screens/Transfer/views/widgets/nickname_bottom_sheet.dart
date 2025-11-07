import 'package:flutter/material.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:banking_app/screens/auth/widgets/button.dart';

class NicknameBottomSheet extends StatefulWidget {
  final Function(String)? onSave;

  const NicknameBottomSheet({super.key, this.onSave});

  @override
  State<NicknameBottomSheet> createState() => _NicknameBottomSheetState();
}

class _NicknameBottomSheetState extends State<NicknameBottomSheet> {
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _saveNickname() {
    if (_formKey.currentState!.validate()) {
      if (widget.onSave != null) {
        widget.onSave!(_nicknameController.text.trim());
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(CommonSize.s20(context)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: CommonSize.s40(context),
              height: CommonSize.s4(context),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          SizedBox(height: CommonSize.s20(context)),

          // Title
          Text(
            'Set up nickname in tra...',
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: CommonSize.s14(context),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: CommonSize.s16(context)),

          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nickname(if any)',
                  style: TextStyle(
                    color: const Color(0xFF002D62),
                    fontSize: CommonSize.s16(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: CommonSize.s8(context)),

                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your favorite nickname',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: CommonSize.s14(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CommonSize.s8(context),
                      ),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CommonSize.s8(context),
                      ),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        CommonSize.s8(context),
                      ),
                      borderSide: const BorderSide(color: Color(0xFF0A3D62)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: CommonSize.s12(context),
                      vertical: CommonSize.s12(context),
                    ),
                  ),
                  style: TextStyle(
                    color: const Color(0xFF002D62),
                    fontSize: CommonSize.s14(context),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a nickname';
                    }
                    return null;
                  },
                ),

                SizedBox(height: CommonSize.s24(context)),

                // Save button
                customElevatedButton(
                  onPressed: _saveNickname,
                  text: 'Save',
                  color: const Color(0xFF0A3D62),
                  textColor: Colors.white,
                  borderRadius: BorderRadius.circular(CommonSize.s8(context)),
                  height: CommonSize.s48(context),
                  width: double.infinity,
                  fontSize: CommonSize.s16(context),
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          SizedBox(height: CommonSize.s20(context)),
        ],
      ),
    );
  }
}
