import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';

enum ButtonSize { small, medium, large }

class ButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final FontWeight? fontWeight;
  final ButtonSize size;

  const ButtonCustom({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.fontWeight,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define size-specific properties
    EdgeInsetsGeometry buttonPadding;
    double fontSize;
    double borderRadiusValue;

    switch (size) {
      case ButtonSize.small:
        buttonPadding =
            padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 16);
        fontSize = 12;
        borderRadiusValue = 24.0;
        break;
      case ButtonSize.large:
        buttonPadding =
            padding ?? EdgeInsets.symmetric(vertical: 20, horizontal: 32);
        fontSize = 16;
        borderRadiusValue = 36.0;
        break;
      case ButtonSize.medium:
      default:
        buttonPadding =
            padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 24);
        fontSize = 14;
        borderRadiusValue = 30.0;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(borderRadiusValue),
          ),
          backgroundColor: backgroundColor ?? AppColors.secondaryColor,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? AppColors.primaryColor,
            fontWeight: fontWeight ?? FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
