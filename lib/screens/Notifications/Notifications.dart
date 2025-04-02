import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationItem {
  final String id;
  final String candidateId;
  final String employerId;
  final String receiverId;
  final String title;
  final String applicationId;
  final String message;
  final bool isRead;
  final String type;
  final String statusTypeApplication;
  final String createdAt;
  final String updatedAt;

  NotificationItem({
    required this.id,
    required this.candidateId,
    required this.employerId,
    required this.receiverId,
    required this.title,
    required this.applicationId,
    required this.message,
    required this.isRead,
    required this.type,
    required this.statusTypeApplication,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<NotificationItem> notifications = [];
  Map<String, dynamic> meta = {};
  bool isLoading = true;
  SecureStorageService secureStorageService = SecureStorageService();

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  Future<void> getNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    try {
      setState(() {
        isLoading = true;
      });

      String endpoint = '';
      if (user?.roleName == 'EMPLOYER') {
        endpoint = 'notifications/employer/${user?.id}';
      } else {
        endpoint = 'notifications/candidate/${user?.id}';
      }

      final response = await ApiService().get(
        dotenv.env['API_URL']! + endpoint,
        token: await secureStorageService.getRefreshToken(),
      );

      if (response['statusCode'] == 200) {
        setState(() {
          notifications =
              (response['data']['items'] as List)
                  .map(
                    (item) => NotificationItem(
                      id: item['_id'] ?? '',
                      candidateId: item['candidateId'] ?? '',
                      employerId: item['employerId'] ?? '',
                      receiverId: item['receiverId'] ?? '',
                      title: item['title'] ?? '',
                      applicationId: item['applicationId'] ?? '',
                      message: item['message'] ?? '',
                      isRead: item['isRead'] ?? false,
                      type: item['type'] ?? '',
                      statusTypeApplication:
                          item['status_type_application'] ?? '',
                      createdAt: item['createdAt'] ?? '',
                      updatedAt: item['updatedAt'] ?? '',
                    ),
                  )
                  .toList();
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markNotificationAsRead(List<String> notificationIds) async {
    try {
      final response = await ApiService().patch(
        dotenv.env['API_URL']! + 'notifications/mark-as-read',
        {'notification_ids': notificationIds},
        token: await secureStorageService.getRefreshToken(),
      );
      print(response);
      if (response['statusCode'] == 200) {
        getNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đọc thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  void markAllAsRead() {
    // Get all unread notification IDs

    List<String> unreadNotificationIds =
        notifications
            .where((notification) => !notification.isRead)
            .map((notification) => notification.id)
            .toList();

    print(unreadNotificationIds);
    if (unreadNotificationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không có thông báo chưa đọc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    markNotificationAsRead(unreadNotificationIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
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
          'Thông báo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: Text(
              'Đánh dấu đã đọc',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? Center(
                child: Text(
                  'Không có thông báo nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                notification.createdAt != null &&
                                        notification.createdAt.isNotEmpty
                                    ? DateFormat('dd-MM-yyyy').format(
                                      DateTime.tryParse(
                                            notification.createdAt,
                                          ) ??
                                          DateTime.now(),
                                    )
                                    : 'No date available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              Text(
                                notification.isRead ? 'Đã đọc' : 'Chưa đọc',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () async {
                        // Mark as read and handle notification tap
                        if (!notification.isRead) {
                          try {
                            await ApiService().post(
                              dotenv.env['API_URL']! +
                                  'notifications/read/${notification.id}',
                              {},
                              token:
                                  await secureStorageService.getRefreshToken(),
                            );
                            // Refresh notifications
                            getNotifications();
                          } catch (e) {
                            print('Error marking notification as read: $e');
                          }
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}
