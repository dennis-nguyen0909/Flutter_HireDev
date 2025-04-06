import 'package:flutter/material.dart';
import 'package:hiredev/modals/ChangePasswordModal.dart';
import 'package:hiredev/modals/SettingNotification.dart';

class SettingModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final modalHeight =
        screenHeight - statusBarHeight - 50; // 50 là khoảng cách từ top xuống

    return Container(
      height: modalHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40), // For balance
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Đổi Mật Khẩu'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        transitionAnimationController: AnimationController(
                          vsync: Navigator.of(context),
                          duration: Duration(milliseconds: 300),
                        ),
                        builder: (BuildContext context) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: ChangePasswordModal(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.visibility_off_outlined),
                    title: Text('Ẩn hồ sơ với Nhà tuyển dụng'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Xử lý sự kiện khi người dùng chọn Ẩn hồ sơ với Nhà tuyển dụng
                      Navigator.pop(context); // Đóng modal bottom sheet
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh_outlined),
                    title: Text('Làm Mới Hồ Sơ'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Xử lý sự kiện khi người dùng chọn Làm Mới Hồ Sơ
                      Navigator.pop(context); // Đóng modal bottom sheet
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications_active_outlined),
                    title: Text('Cài Đặt Thông Báo'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return SettingNotificationModal();
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.work_outline),
                    title: Text('Cài Đặt Thông Báo Việc Làm'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Xử lý sự kiện khi người dùng chọn Cài Đặt Thông Báo Việc Làm
                      Navigator.pop(context); // Đóng modal bottom sheet
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
