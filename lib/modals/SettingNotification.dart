import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/userServices.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SettingNotificationModal extends StatefulWidget {
  @override
  _SettingNotificationModalState createState() =>
      _SettingNotificationModalState();
}

class _SettingNotificationModalState extends State<SettingNotificationModal> {
  bool _notifyWhenSaved = true;
  bool _notifyWhenRejected = true;
  bool _isUpdating = false;
  List<String> _errorMessage = [];
  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final user = context.read<UserProvider>().user;

    if (user != null) {
      setState(() {
        _notifyWhenSaved = user.notificationWhenEmployerSaveProfile ?? true;
        _notifyWhenRejected = user.notificationWhenEmployerRejectCv ?? true;
      });
    }
  }

  Future<void> _updateNotificationSettings({
    required String settingType,
    required bool value,
  }) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      _errorMessage = [];
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      Map<String, dynamic> updateData = {
        'id': user?.id ?? "67e74c5cf5890770fa4b7189",
      };

      // Only update the specific setting that changed
      if (settingType == 'saved') {
        updateData['notification_when_employer_save_profile'] = value;
      } else if (settingType == 'rejected') {
        updateData['notification_when_employer_reject_cv'] = value;
      }

      final response = await UserServices.updateUser(
        updateData,
        context: context,
      );

      if (response != null && response['statusCode'] == 200) {
      } else {
        setState(() {
          if (response != null && response['message'] is List) {
            _errorMessage = List<String>.from(response['message']);
          } else if (response != null && response['message'] is String) {
            _errorMessage = [response['message']];
          } else {
            _errorMessage = ['Failed to update notification settings'];
          }

          // Revert the switch if there was an error
          if (settingType == 'saved') {
            _notifyWhenSaved = !value;
          } else if (settingType == 'rejected') {
            _notifyWhenRejected = !value;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = [e.toString()];
        // Revert the switch if there was an error
        if (settingType == 'saved') {
          _notifyWhenSaved = !value;
        } else if (settingType == 'rejected') {
          _notifyWhenRejected = !value;
        }
      });
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final modalHeight = screenHeight - statusBarHeight - 50;

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
                  icon: Icon(Icons.arrow_back_ios_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Cài Đặt Thông Báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Thông báo cho tôi khi nhà tuyển dụng lưu hồ sơ của tôi',
                        ),
                        value: _notifyWhenSaved,
                        onChanged: (bool value) {
                          setState(() {
                            _notifyWhenSaved = value;
                          });
                          _updateNotificationSettings(
                            settingType: 'saved',
                            value: value,
                          );
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      if (_isUpdating &&
                          _notifyWhenSaved != _notifyWhenRejected)
                        Positioned(
                          right: 60,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Divider(),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Thông báo cho tôi khi nhà tuyển dụng từ chối tôi',
                        ),
                        value: _notifyWhenRejected,
                        onChanged: (bool value) {
                          setState(() {
                            _notifyWhenRejected = value;
                          });
                          _updateNotificationSettings(
                            settingType: 'rejected',
                            value: value,
                          );
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                      if (_isUpdating &&
                          _notifyWhenSaved == _notifyWhenRejected)
                        Positioned(
                          right: 60,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage.join('\n'),
                        style: TextStyle(color: Colors.red),
                      ),
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
