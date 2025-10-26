import 'package:banking_app/screens/nickname/styles/style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final void Function(String) onChanged;
  final bool? enabled;
  final TextInputType keyboardType;


  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3,
      children: [
        Text(label, style: subTitleStyle(context)),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintTextStyle(ctx: context),
            border: const UnderlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
