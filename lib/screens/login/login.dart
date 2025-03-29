import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/forgotPassword/ForgetPassword.dart';
import 'package:hiredev/screens/register/Register.dart';
import 'package:hiredev/screens/verify/EmailVerificationScreen.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/app_main_screen.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:provider/provider.dart'; // Import Provider

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tạo TextEditingController cho email và password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final SecureStorageService secureStorageService = SecureStorageService();

  Future<void> retryActive(String email) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "auth/retry-active",
      {'email': email},
    );
    print(response);
  }

  Future<void> fetchData(String username, String password) async {
    try {
      // Sử dụng ApiService để gọi POST request
      final response = await ApiService().post(
        dotenv.env['API_URL']! + "auth/login",
        {'username': username, 'password': password},
        token: await secureStorageService.getAccessToken(),
      );
      if (response['statusCode'] == 400) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${response['message']}')));
        return;
      }
      if (response['statusCode'] == 400 && response['code'] == 'not_active') {
        await retryActive(username);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EmailVerificationScreen(
                  email: username,
                  id: response['userId'],
                ),
          ),
        );
        return;
      }
      print("response: ${response}");
      // Kiểm tra nếu phản hồi có 'data' và 'user'
      if (response != null &&
          response['data'] != null &&
          response['data']['user'] != null) {
        String accessToken = response['data']['user']['access_token'];
        String refreshToken = response['data']['user']['refresh_token'];
        String userId =
            response['data']['user']['user_id']; // Lấy user_id ở đây

        // Lưu token vào secure storage
        await secureStorageService.saveToken(accessToken, refreshToken);
        await secureStorageService.saveUserId(userId);

        // Gọi fetchUserDetails của UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUserDetails(userId);

        // Điều hướng tới màn hình khác sau khi đăng nhập thành công
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppMainScreen()),
        );
      } else {}
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
  }

  Future<void> _loginWithFacebook() async {
    try {
      final result = await FlutterWebAuth.authenticate(
        url: dotenv.env['API_LOGIN_FACEBOOK']!,
        callbackUrlScheme: "myapp",
      );

      final uri = Uri.parse(result);
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      // Bạn cần một API endpoint để xác thực Facebook token và lấy user_id
      // Ví dụ:
      // final response = await ApiService().post(
      //   dotenv.env['API_URL']! + "auth/facebook",
      //   {'access_token': accessToken},
      // );
      // if (response != null && response['data'] != null && response['data']['_id'] != null) {
      //   final userId = response['data']['_id'];
      //   await secureStorageService.saveToken(accessToken, refreshToken ?? '');
      //   final userProvider = Provider.of<UserProvider>(context, listen: false);
      //   await userProvider.fetchUserDetails(userId);
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => AppMainScreen()),
      //   );
      // } else {
      //   // Xử lý lỗi
      // }
      print('Access token: $accessToken');
      print('Refresh token: $refreshToken');
    } catch (e) {
      print('Lỗi đăng nhậpqqq: $e');
    }
  }

  void handleLoginGoogle() {
    print('Đăng nhập với Google');
    // Tương tự, cần tích hợp Google Sign-In và sau đó gọi API backend để lấy user_id
    // và gọi fetchUserDetails
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
                Image.asset('assets/LogoH.png', height: 80),

                SizedBox(height: 30),

                Text(
                  "Đăng nhập.",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Bạn chưa có tài khoản? Tạo tài khoản",
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                  ),
                ),

                SizedBox(height: 30),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgetPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Quên mật khẩu?",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
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
