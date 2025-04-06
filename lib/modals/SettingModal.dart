import 'package:flutter/material.dart';
import 'package:hiredev/modals/ChangePasswordModal.dart';
import 'package:hiredev/modals/SettingNotification.dart';
import 'package:hiredev/modals/SocialMediaModal.dart';

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
                  Text("Tài khoản"),
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
                          return Container(
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
                    leading: Icon(Icons.lock_outline),
                    title: Text('Liên kết xã hội'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                            // width: MediaQuery.of(context).size.width,
                            child: SocialMediaModal(),
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.more_horiz),
                    title: Text('Khác'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Container(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    'Xóa tài khoản',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () {
                                    // Xử lý xóa tài khoản
                                    Navigator.pop(context);
                                  },
                                ),
                                Divider(),
                                ListTile(
                                  leading: Icon(Icons.close),
                                  title: Text('Đóng'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Divider(),

                  Text("Thông báo"),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
