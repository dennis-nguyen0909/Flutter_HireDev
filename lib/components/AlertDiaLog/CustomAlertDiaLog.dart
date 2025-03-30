import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onPressed;
  final String? logoAssetPath; // Optional logo path

  CustomAlertDialog({
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onPressed,
    this.logoAssetPath, // Make logo optional
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ), // More rounded
      titlePadding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
      ), // Padding around title
      contentPadding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 20,
      ), // Padding around content
      actionsPadding: EdgeInsets.only(
        bottom: 24,
        right: 16,
      ), // Padding around actions
      title: Row(
        children: [
          if (logoAssetPath != null) // Conditional logo display
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Image.asset(
                logoAssetPath!,
                height: 30, // Adjust logo height
                width: 30, // Adjust logo width
              ),
            ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: Colors.indigo,
              ), // Style title
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[700],
        ), // Style content
      ),
      actions: [
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Button text color
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
            ), // Button text style
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ), // Button padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ), // Rounded button
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }
}
