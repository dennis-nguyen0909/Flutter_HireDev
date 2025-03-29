import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/SplashScreen/SplashScreen.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/login/Login.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/views/app_main_screen.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider(ApiService())),
        // Các providers khác nếu có
      ],
      child: MaterialApp(
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
        home: AuthChecker(),
      ),
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
  bool _isLoading = true; // Thêm trạng thái loading

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Hàm để kiểm tra trạng thái token
  Future<void> _checkAuthStatus() async {
    String? token = await secureStorageService.getAccessToken();
    String? userId = await secureStorageService.getUserId();
    if (token != null && token.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final UserModel? user = userProvider.user;

      try {
        await userProvider.fetchUserDetails(userId!);
      } catch (e) {
        print('Error checking auth: $e');
        await secureStorageService.deleteAccessToken();
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? SplashScreen()
        : Container(); // Hiển thị SplashScreen khi loading, hoặc một widget trống nếu đã load xong
  }
}
