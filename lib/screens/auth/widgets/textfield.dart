import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget customTextField({
  required TextEditingController controller,
  String? hintText,
  bool isPassword = false,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
  TextInputAction textInputAction = TextInputAction.done,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool showPasswordToggle = false,
  int? maxLength,
  int? maxLines = 1,
  bool autofocus = false,
  List<TextInputFormatter>? inputFormatters,
  Color? fillColor,
  bool filled = false,
  Color? borderColor,
  double borderRadius = 8,
  TextStyle? hintStyle = const TextStyle(color: Colors.grey),
  Color? prefixIconColor = Colors.grey,
  Color? suffixIconColor = Colors.grey,
  VoidCallback? onEditingComplete,
  TextStyle? textStyle,
  TextStyle? errorStyle,
  bool? enabled = true,
  String? initialValue = ''
}) {
  return _CustomTextField(
    controller: controller,
    hintText: hintText,
    isPassword: isPassword,

    readOnly: readOnly,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    validator: validator,
    onChanged: onChanged,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    showPasswordToggle: showPasswordToggle,
    maxLength: maxLength,
    maxLines: maxLines,
    autofocus: autofocus,
    inputFormatters: inputFormatters,
    fillColor: fillColor,
    filled: filled,
    borderColor: borderColor,
    borderRadius: borderRadius,
    hintStyle: hintStyle,
    prefixIconColor: prefixIconColor,
    suffixIconColor: suffixIconColor,
    onEditingComplete: onEditingComplete,
    textStyle: textStyle,
    errorStyle: errorStyle,
    enabled: enabled,
    initialValue: initialValue,
  );
}

class _CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showPasswordToggle;
  final int? maxLength;
  final int? maxLines;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final bool filled;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? hintStyle;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final VoidCallback? onEditingComplete;
  final TextStyle? textStyle;
  final TextStyle? errorStyle;
  final bool? enabled;
  final String? initialValue;

  const _CustomTextField({
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.showPasswordToggle = false,
    this.maxLength,
    this.maxLines = 1,
    this.autofocus = false,
    this.inputFormatters,
    this.fillColor,
    this.filled = false,
    this.borderColor,
    this.borderRadius = 8,
    this.hintStyle,
    this.prefixIconColor = Colors.grey,
    this.suffixIconColor = Colors.grey,
    this.onEditingComplete,
    this.textStyle,
    this.errorStyle,
    this.enabled,
    this.initialValue
  });

  @override
  State<_CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<_CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.initialValue ?? '').isNotEmpty && widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialValue!;
    }
    return TextFormField(
      enabled:  widget.enabled,
      style: widget.textStyle,
      onEditingComplete: widget.onEditingComplete,
      controller: widget.controller,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      cursorColor: Colors.white,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        filled: widget.filled,
        fillColor: widget.fillColor,
        prefixIcon: widget.prefixIcon,
        prefixIconColor: widget.prefixIconColor,
        suffixIconColor: widget.suffixIconColor,
        errorStyle: widget.errorStyle,
        suffixIcon:
            widget.showPasswordToggle
                ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                : widget.suffixIcon,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
