import 'package:flutter/material.dart';

enum InputType { input, textarea } // Định nghĩa enum cho loại trường

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final InputType type; // Thêm tùy chọn type

  CustomInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
    this.type = InputType.input, // Giá trị mặc định là input
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              if (required) Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          SizedBox(height: 8),
          type == InputType.input
              ? TextField(
                // Hiển thị TextField nếu type là input
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: hint,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                ),
              )
              : TextField(
                // Hiển thị TextField với maxLines nếu type là textarea
                controller: controller,
                maxLines: 5, // Đặt maxLines cho textarea
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: hint,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
