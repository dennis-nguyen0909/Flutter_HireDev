import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? colorIcon;

  TextIcon({
    required this.icon,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.colorIcon = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: colorIcon),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}
