import 'package:flutter/material.dart';

class CustomSelectOption<T> extends StatefulWidget {
  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;

  CustomSelectOption({
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
  });

  @override
  _CustomSelectOptionState<T> createState() => _CustomSelectOptionState<T>();
}

class _CustomSelectOptionState<T> extends State<CustomSelectOption<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          // Bao bọc DropdownButton trong Container
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<T>(
            value: _selectedValue,
            onChanged: (T? newValue) {
              setState(() {
                _selectedValue = newValue;
              });
              widget.onChanged(newValue);
            },
            items: widget.items,
            isExpanded: true,
            underline: SizedBox(),
            style: TextStyle(fontSize: 16, color: Colors.black),
            icon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ],
    );
  }
}
