import 'package:flutter/material.dart';

class CustomGenderDropdown extends StatefulWidget {
  final int? initialValue;
  final ValueChanged<int> onChanged;

  CustomGenderDropdown({this.initialValue, required this.onChanged});

  @override
  _CustomGenderDropdownState createState() => _CustomGenderDropdownState();
}

class _CustomGenderDropdownState extends State<CustomGenderDropdown> {
  int? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới tính',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<int>(
              value: _selectedGender,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedGender = newValue ?? 0;
                });
                widget.onChanged(newValue ?? 0);
              },
              items: <DropdownMenuItem<int>>[
                DropdownMenuItem<int>(value: 0, child: Text('Nam')),
                DropdownMenuItem<int>(value: 1, child: Text('Nữ')),
                DropdownMenuItem<int>(value: 2, child: Text('Không xác định')),
              ],
              hint: Text('Chọn giới tính'),
              isExpanded:
                  true, // Cho phép DropdownButton mở rộng theo chiều rộng Container
              underline: SizedBox(), // Loại bỏ đường gạch chân mặc định
              style: TextStyle(fontSize: 16, color: Colors.black),
              icon: Icon(Icons.arrow_drop_down),
            ),
          ),
        ),
      ],
    );
  }
}
