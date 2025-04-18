import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/Companies/Companies.dart';
import 'package:hiredev/components/SettingCv/SettingCv.dart';
import 'package:hiredev/modals/SettingModal.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/AccountManagement/AccountManagement.dart';
import 'package:hiredev/screens/ProfileScreen/ProfileScreen.dart';
import 'package:hiredev/screens/login/Login.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/myjob/MyJobScreen.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  final SecureStorageService secureStorageService = SecureStorageService();
  bool _isLoading = false;
  int _profileCompletion = 0;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileCompletion();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> profileCompletion() async {
    final user = context.read<UserProvider>().user;
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await ApiService().get(
        dotenv.get('API_URL') + 'users/${user?.id}/profile-completion',
        token: await secureStorageService.getRefreshToken(),
      );
      print(response);
      if (response['statusCode'] == 200) {
        setState(() {
          _profileCompletion = response['data'];
          // Update the animation target and start it
          _progressAnimation = Tween<double>(
            begin: 0,
            end: _profileCompletion / 100,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
          _animationController.forward();
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      backgroundColor: Colors.white,
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _progressAnimation.value,
                                strokeWidth: 5,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFDA4156),
                                ),
                              );
                            },
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child:
                              user?.avatar != null
                                  ? Image.network(
                                    user?.avatar ?? '',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/avatar_default.jpg',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ],
                    ),
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
                                ).then((_) {
                                  // Refresh profile completion when returning from ProfileScreen
                                  profileCompletion();
                                }),
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
                    ).then((_) {
                      // Refresh profile completion when returning from MyJobScreen
                      profileCompletion();
                    });
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return SettingModal();
                        },
                      );
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
                          backgroundColor: Colors.grey.shade200,
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
