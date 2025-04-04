import 'package:flutter/material.dart';

class AccountManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildListItem(context, Icons.settings, 'Cài đặt', () {
              // Xử lý khi nhấn vào cài đặt
            }),
            _buildListItem(context, Icons.language, 'Ngôn ngữ', () {
              // Xử lý khi nhấn vào ngôn ngữ
            }),
            _buildListItem(
              context,
              Icons.question_answer,
              'Câu hỏi thường gặp',
              () {
                // Xử lý khi nhấn vào câu hỏi thường gặp
              },
            ),
            _buildListItem(context, Icons.feedback, 'Gửi phản hồi', () {
              // Xử lý khi nhấn vào gửi phản hồi
            }),
            _buildListItem(context, Icons.more_horiz, 'Xem thêm', () {
              // Xử lý khi nhấn vào xem thêm
            }),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xử lý khi nhấn vào đăng xuất
              },
              child: Text('Đăng xuất'),
            ),
            SizedBox(height: 10),
            Text(
              'Version 4.0.2',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    IconData icon,
    String title,
    Function onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        onTap();
      },
    );
  }
}
