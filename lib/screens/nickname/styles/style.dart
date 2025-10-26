import 'package:banking_app/core/AppStyles/app_styles.dart';
import 'package:banking_app/screens/auth/widgets/size.dart';
import 'package:flutter/material.dart';

TextStyle titleTextStyle(context) {
  return TextStyle(
    fontSize: CommonSize.s24(context),
    fontWeight: FontWeight.w500,
  );
}

TextStyle subTitleStyle(context) {
  return TextStyle(
    fontSize: CommonSize.s20(context),
    fontWeight: FontWeight.w500,
  );
}

TextStyle normalTextStyle({required BuildContext ctx, bool isBold = false, Color color = Colors.black}){
  return TextStyle(
    fontSize: CommonSize.s16(ctx),
    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
    color: color
  );
}


TextStyle hintTextStyle({required BuildContext ctx, bool isBold = false, Color color = AppStyles.textSecondary}){
  return TextStyle(
    fontSize: CommonSize.s12(ctx),
    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
    color: color
  );
}