import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/screens/ResetPassword/ResetPasswordScreen.dart';
import 'package:hiredev/screens/login/Login.dart';
import 'package:hiredev/screens/register/Register.dart';
import 'package:hiredev/services/apiServices.dart';

class ForgetPasswordScreen extends StatefulWidget {
  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  bool isSuccess = false;
  Future<void> forgetPassword() async {
    setState(() {
      isLoading = true;
    });
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email is required')));
      return;
    }
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "auth/forgot-password",
      {'email': emailController.text},
    );
    print("duydeptrai: ${response['status']}");
    if (response['statusCode'] == 201) {
      setState(() {
        isSuccess = true;
      });
    }
    if (response['status'] == 400) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'])));
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> verifyOtp() async {
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "auth/verify-otp",
      {'email': emailController.text, 'otp': otpController.text},
    );
    print("duydeptrai: $response");
    if (response['statusCode'] == 201) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ResetPasswordScreen(email: emailController.text),
        ),
      );
    }
    if (response['statusCode'] == 400) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'])));
      return;
    }
    if (response['response']['response']['statusCode'] == 400) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['response']['message'])));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Forget Password.',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Go back to? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'SignIn',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don’t have account '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              isSuccess
                  ? TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      hintText: 'OTP',
                      border: OutlineInputBorder(),
                    ),
                  )
                  : SizedBox(),
              SizedBox(height: 10),
              isSuccess
                  ? Center(
                    child: GestureDetector(
                      onTap: () {
                        forgetPassword();
                      },
                      child: Text(
                        "Don't receive OTP? Resend OTP",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  )
                  : SizedBox(),
              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isSuccess) {
                      verifyOtp();
                    } else {
                      forgetPassword();
                    }
                  },
                  child: Text(
                    isSuccess ? "Verify OTP" : "Reset password",
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
            ],
          ),
        ),
      ),
    );
  }
}
