import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/app_main_screen.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tạo TextEditingController cho email và password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SecureStorageService secureStorageService = SecureStorageService();
  Future<void> fetchData(String username, String password) async {
    try {
      // Sử dụng ApiService để gọi POST request
      final response = await ApiService().post(
        dotenv.env['API_URL']! + "auth/login",
        {'username': username, 'password': password},
      );

      // Kiểm tra nếu phản hồi có 'data' và 'user'
      if (response != null &&
          response['data'] != null &&
          response['data']['user'] != null) {
        String accessToken = response['data']['user']['access_token'];
        String refreshToken = response['data']['user']['refresh_token'];

        // Lưu token vào secure storage
        await secureStorageService.saveToken(accessToken, refreshToken);

        // Điều hướng tới màn hình khác sau khi đăng nhập thành công
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppMainScreen()),
        );
      } else {
        // Hiển thị thông báo lỗi từ server nếu dữ liệu không hợp lệ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng nhập thất bại: Dữ liệu phản hồi không hợp lệ"),
          ),
        );
      }
    } catch (e) {
      // Hiển thị lỗi từ server qua SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${e.toString()}')));
    }
  }

  // Hàm xử lý khi nhấn nút Đăng nhập
  void _handleLogin() {
    final email = emailController.text;
    final password = passwordController.text;

    // Kiểm tra nếu email và password không rỗng
    if (email.isEmpty || password.isEmpty) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ email và mật khẩu")),
      );
      return;
    }

    fetchData(email, password);

    // Logic xử lý đăng nhập ở đây
    print('Email: $email');
    print('Password: $password');
    // Thêm các bước kiểm tra email, gửi yêu cầu đăng nhập lên server...
  }

  Future<void> _loginWithFacebook() async {
    try {
      // Gọi endpoint API để thực hiện OAuth login với Facebook
      final result = await FlutterWebAuth.authenticate(
        url: dotenv.env['API_LOGIN_FACEBOOK']!, // URL API login Facebook
        callbackUrlScheme:
            "myapp", // Scheme của callback URL (phải trùng với Info.plist)
      );

      // Parse URL để lấy access_token và refresh_token
      final uri = Uri.parse(result);
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      // Xử lý token đăng nhập (lưu token, điều hướng trang, etc.)
      print('Access token: $accessToken');
      print('Refresh token: $refreshToken');

      // Có thể lưu trữ token vào secure storage hoặc điều hướng người dùng vào ứng dụng chính
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Lỗi đăng nhậpqqq: $e');
    }
  }

  void handleLoginGoogle() {
    print('Đăng nhập với Google');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/LogoH.png',
                  height: 80,
                ), // Thay bằng logo của bạn

                SizedBox(height: 30),

                // Form Đăng Nhập
                Text(
                  "Đăng nhập.",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "Bạn chưa có tài khoản? Tạo tài khoản",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),

                SizedBox(height: 30),

                // Email input
                TextFormField(
                  controller: emailController, // Gán controller cho email
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16),

                // Password input
                TextFormField(
                  controller: passwordController, // Gán controller cho password
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Ghi nhớ tài khoản và Quên mật khẩu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (value) {}),
                        Text("Ghi nhớ tài khoản"),
                      ],
                    ),
                    Text(
                      "Quên mật khẩu?",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Button Đăng Nhập
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin, // Gọi hàm xử lý khi nhấn Đăng nhập
                    child: Text(
                      "Đăng nhập",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: AppColors.secondaryColor,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Text("hoặc", style: TextStyle(fontSize: 16)),

                SizedBox(height: 16),

                // Đăng nhập với Facebook
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                    onPressed: _loginWithFacebook,
                    label: Text("Đăng nhập với Facebook"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Đăng nhập với Google
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
                    onPressed: handleLoginGoogle,
                    label: Text("Đăng nhập với Google"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
