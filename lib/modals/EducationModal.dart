import 'package:flutter/material.dart';

class EducationModal extends StatefulWidget {
  @override
  _EducationModalState createState() => _EducationModalState();
}

class _EducationModalState extends State<EducationModal> {
  String? _selectedDegree;
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: ConstrainedBox(
        // Thêm ConstrainedBox để giới hạn chiều cao
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              0.8, // Chiếm 80% chiều cao màn hình
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thêm học vấn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.black87, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Chuyên ngành',
                hintText: 'Bắt buộc',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Trường học',
                hintText: 'Bắt buộc',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Bằng cấp'),
            Wrap(
              spacing: 8.0,
              children:
                  [
                    'Trung học',
                    'Trung cấp',
                    'Cao đẳng',
                    'Cử nhân',
                    'Thạc sĩ',
                    'Tiến sĩ',
                    'Khác',
                  ].map((String degree) {
                    return ChoiceChip(
                      label: Text(degree),
                      selected: _selectedDegree == degree,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedDegree = selected ? degree : null;
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Từ tháng',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _fromDate == null
                            ? 'mm / yyyy'
                            : '${_fromDate!.month} / ${_fromDate!.year}',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Đến tháng',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _toDate == null
                            ? 'mm / yyyy'
                            : '${_toDate!.month} / ${_toDate!.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Thành tựu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý lưu thông tin học vấn
                  Navigator.pop(context);
                },
                child: Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
