import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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
  bool isLoading = false;
  Future<void> retryActive(String email) async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "auth/retry-active",
      {'email': email},
    );
    print(response);
  }

  Future<void> fetchData(String username, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      // Sử dụng ApiService để gọi POST request
      final response = await ApiService().post(
        dotenv.env['API_URL']! + "auth/login",
        {'username': username, 'password': password},
        token: await secureStorageService.getAccessToken(),
      );
      print("response: ${response}");
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
      if (response['statusCode'] == 400) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${response['message']}')));
        return;
      }
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
    } finally {
      setState(() {
        isLoading = false;
      });
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
      final LoginResult result = await FacebookAuth.instance.login();
      print("result: ${result}");
      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();
        print("userData: ${userData}");

        // Check if last_name or first_name is null before concatenation
        String fullName = '';
        if (userData['last_name'] != null && userData['first_name'] != null) {
          fullName = userData['last_name'] + ' ' + userData['first_name'];
        } else if (userData['name'] != null) {
          fullName = userData['name'];
        } else {
          fullName = 'Facebook User'; // Default name if no name data available
        }

        final params = {
          'email': userData['email'] ?? '',
          'full_name': fullName,
          'avatar': userData['picture']?['data']?['url'] ?? '',
          'password': '',
          'authProvider': "6770b193b50eecacbb8e0c61",
          'account_type': "6770b193b50eecacbb8e0c61",
        };
        final response = await ApiService().post(
          dotenv.env['API_URL']! + "users/validate-facebook",
          params,
        );
        print("response: ${response}");
      } else {
        print(result.status);
        print(result.message);
      }
    } catch (error) {
      print(error);
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
                      isLoading ? "Đang đăng nhập..." : "Đăng nhập",
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
