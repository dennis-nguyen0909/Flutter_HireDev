import 'package:flutter/material.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/screens/login/login.dart';

class Account extends StatefulWidget {
  @override
  _StateAccount createState() => _StateAccount();
}

class _StateAccount extends State<Account> {
  final SecureStorageService secureStorageService = SecureStorageService();

  // Hàm đăng xuất và xóa token
  Future<void> _logout() async {
    await secureStorageService.removeTokens(); // Xóa token khỏi SecureStorage

    // Điều hướng về màn hình đăng nhập sau khi đăng xuất
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: secureStorageService.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Lỗi khi lấy token: ${snapshot.error}"));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Token: ${snapshot.data}"),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _logout, child: Text("Đăng xuất")),
            ],
          );
        }

        return Center(child: Text("Không tìm thấy token"));
      },
    );
  }
}
