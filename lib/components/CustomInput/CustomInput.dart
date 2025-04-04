import 'package:flutter/material.dart';

enum InputType { input, textarea } // Định nghĩa enum cho loại trường

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final InputType type; // Thêm tùy chọn type
  final bool disabled; // Thêm tùy chọn disabled

  CustomInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.required = false,
    this.type = InputType.input, // Giá trị mặc định là input
    this.disabled = false, // Giá trị mặc định là không bị vô hiệu hóa
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
                enabled: !disabled, // Vô hiệu hóa nếu disabled = true
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: hint,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  fillColor:
                      disabled
                          ? Colors.grey[200]
                          : Colors.white, // Màu nền khi bị vô hiệu hóa
                  filled: true,
                ),
              )
              : TextField(
                // Hiển thị TextField với maxLines nếu type là textarea
                controller: controller,
                enabled: !disabled, // Vô hiệu hóa nếu disabled = true
                maxLines: 5, // Đặt maxLines cho textarea
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: hint,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  fillColor:
                      disabled
                          ? Colors.grey[200]
                          : Colors.white, // Màu nền khi bị vô hiệu hóa
                  filled: true,
                ),
              ),
        ],
      ),
    );
  }
}
