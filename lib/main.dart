import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/SplashScreen/SplashScreen.dart';
import 'package:hiredev/screens/login/login.dart';
import 'package:hiredev/views/app_main_screen.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Color(0xFF666666),
          ),
        ),
      ),
      home: AuthChecker(), // Sử dụng AuthChecker để kiểm tra token
    );
  }
}

// Widget để kiểm tra token và điều hướng
class AuthChecker extends StatefulWidget {
  @override
  _AuthCheckerState createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final SecureStorageService secureStorageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Hàm để kiểm tra trạng thái token
  Future<void> _checkAuthStatus() async {
    String? token = await secureStorageService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      // Nếu có token, điều hướng đến AppMainScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AppMainScreen()),
      );
    } else {
      // Nếu không có token, điều hướng đến LoginScreen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị màn hình chờ (SplashScreen) trong khi kiểm tra token
    return SplashScreen(); // Hoặc có thể dùng CircularProgressIndicator để hiển thị loading
  }
}
