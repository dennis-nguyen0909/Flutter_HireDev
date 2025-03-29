import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/app_main_screen.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String id;
  EmailVerificationScreen({required this.email, required this.id});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController codeController = TextEditingController();
  final SecureStorageService secureStorageService = SecureStorageService();
  bool isLoading = false;
  int countdown = 0;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> retryActive(String email) async {
    setState(() {
      countdown = 30; // Bắt đầu đếm ngược từ 30 giây
    });
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          t.cancel();
        }
      });
    });

    final response = await ApiService().post(
      dotenv.env['API_URL']! + "auth/retry-active",
      {'email': email},
    );
    print(response);
  }

  Future<void> verifyEmail(String id, String code_id) async {
    setState(() {
      isLoading = true;
    });
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "auth/verify",
      {'id': id, 'code_id': code_id},
    );
    if (response['statusCode'] == 201) {
      String accessToken = response['data']['access_token'];
      String refreshToken = response['data']['refresh_token'];
      String userId = response['data']['user_id']; // Lấy user_id ở đây

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
      return;
    }
    if (response['statusCode'] == 401) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'])));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Email Verification',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "We've sent a verification to ${widget.email} to verify your email address and activate your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    verifyEmail(widget.id, codeController.text);
                  },
                  child:
                      isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            "Verify",
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
              TextButton(
                onPressed:
                    countdown == 0
                        ? () {
                          retryActive(widget.email);
                        }
                        : null, // Vô hiệu hóa nút khi đang đếm ngược
                child:
                    countdown > 0
                        ? Text('Please wait $countdown seconds to resend')
                        : Text('Didn’t receive any code? Resend'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
