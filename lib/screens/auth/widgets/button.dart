import 'package:banking_app/AppStyles/Style.dart';
import 'package:flutter/material.dart';


Widget customElevatedButton({
  required String text,
  VoidCallback? onPressed,required BuildContext context,
  
  bool isLoading = false,
  Color? color,
  Color? textColor,
  double? height,
  double? width,
  double? fontSize,
  FontWeight? fontWeight,
  BorderRadius? borderRadius,
}) {
 final theme = Theme.of(context);
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(color ?? Colors.blue),
      minimumSize: WidgetStateProperty.all(
        Size(width ?? double.infinity, height ?? 48),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    ),
    onPressed: isLoading ? null : onPressed,
    child: isLoading
        ?  SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2,backgroundColor: 
            theme.colorScheme.brightness == Brightness.light ? Colors.white : AppColors.deepNavy,),
          )
        : Text(text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: fontWeight ?? FontWeight.normal,
              color: textColor ?? Colors.black,
            )),
  );
}