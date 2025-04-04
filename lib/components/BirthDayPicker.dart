import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthdayPicker extends StatefulWidget {
  final DateTime? initialDateOfBirth;
  final ValueChanged<DateTime> onDateOfBirthChanged;

  BirthdayPicker({this.initialDateOfBirth, required this.onDateOfBirthChanged});

  @override
  _BirthdayPickerState createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _selectedDateOfBirth = widget.initialDateOfBirth;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày sinh',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            _selectDate(context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDateOfBirth == null
                      ? 'Chọn ngày sinh'
                      : DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!),
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
      widget.onDateOfBirthChanged(picked);
    }
  }
}
