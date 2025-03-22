import 'package:flutter/material.dart';
import 'package:hiredev/views/app_main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Chuyển sang màn hình chính sau 3 giây
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppMainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/LogoH.png',
              width: 150,
              height: 150,
            ), // Đường dẫn
            (SizedBox(height: 20)),
            Text("Tiếp lợi thế , Nối thành công"),
          ],
        ),
      ),
    );
  }
}
