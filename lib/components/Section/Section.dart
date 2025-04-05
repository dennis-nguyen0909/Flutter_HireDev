import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';

class SectionComponent extends StatelessWidget {
  final String title;
  final String description;
  final Widget modalContent;
  final List<dynamic> items;
  final Widget Function(dynamic)? renderItem;

  SectionComponent({
    required this.title,
    required this.description,
    required this.modalContent,
    this.items = const [],
    this.renderItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                _showModal(context);
              },
              icon: Icon(Icons.add, color: AppColors.primaryColor),
              label: Text(
                'Thêm',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
        if (items.isEmpty)
          Text(description, style: TextStyle(fontSize: 14, color: Colors.grey)),
        if (items.isNotEmpty && renderItem != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => renderItem!(item)).toList(),
          ),
        SizedBox(height: 16),
        Divider(), // Đường kẻ phân cách
      ],
    );
  }

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: modalContent,
        );
      },
    );
  }
}
