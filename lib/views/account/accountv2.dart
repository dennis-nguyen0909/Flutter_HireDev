import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/Companies/Companies.dart';
import 'package:hiredev/components/SettingCv/SettingCv.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/AccountManagement/AccountManagement.dart';
import 'package:hiredev/screens/ProfileScreen/ProfileScreen.dart';
import 'package:hiredev/screens/login/Login.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/myjob/MyJobScreen.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final SecureStorageService secureStorageService = SecureStorageService();

  Future<void> _logout() async {
    await secureStorageService.removeTokens();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDA4156), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          'Menu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.left,
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // User Info Section
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    user?.avatar != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            user?.avatar ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                        : SizedBox(width: 16.0),
                    SizedBox(width: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user?.fullName ?? '123',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          '${user?.totalExperienceYears != null ? user?.totalExperienceYears : 0} năm kinh nghiệm',
                          style: TextStyle(color: Colors.black),
                        ),
                        GestureDetector(
                          onTap:
                              () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(),
                                  ),
                                ),
                              },
                          child: Text(
                            'Hồ Sơ Của Tôi',
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0), // Add some space after logout button
              // Job Management Section
              Text(
                'Quản lý nghề nghiệp',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 2,
                children: <Widget>[
                  _buildMenuItem('Việc của tôi', Icons.work, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyJobScreen()),
                    );
                  }),
                  _buildMenuItem('Thông báo việc làm', Icons.notifications, () {
                    // Xử lý khi nhấn vào thông báo việc làm
                  }),
                  _buildMenuItem('Công ty của tôi', Icons.business, () {
                    // Xử lý khi nhấn vào công ty của tôi
                  }),
                  _buildMenuItem('Ẩn hồ sơ', Icons.visibility_off, () {
                    // Xử lý khi nhấn vào ẩn hồ sơ
                  }),
                  _buildMenuItem('Quản lý đơn hàng', Icons.shopping_cart, () {
                    // Xử lý khi nhấn vào quản lý đơn hàng
                  }),
                ],
              ),
              SizedBox(height: 16.0),
              // Profile Settings Section
              SettingCv(),
              SizedBox(height: 16.0),
              Companies(),
              SizedBox(height: 16.0),
              Text(
                "Quản lý tài khoản",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(0.0),

                child: Column(
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Xử lý khi nhấn vào đăng xuất
                          _logout();
                        },
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: Color(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, Function? onTap) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: AppColors.primaryColor),
            SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildListItem(
  BuildContext context,
  IconData icon,
  String title,
  Function onTap,
) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        onTap();
      },
    ),
  );
}
