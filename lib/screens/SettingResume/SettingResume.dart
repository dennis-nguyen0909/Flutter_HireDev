import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/CustomNotification/CustomNotification.dart';
import 'package:hiredev/components/SettingCv/SettingCv.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/services/fileService.dart';
import 'package:hiredev/services/userServices.dart';
import 'package:hiredev/utils/DocumentViewer.dart';
import 'package:hiredev/utils/FileSystem.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeSettingsScreen extends StatefulWidget {
  @override
  _ResumeSettingsScreenState createState() => _ResumeSettingsScreenState();
}

class _ResumeSettingsScreenState extends State<ResumeSettingsScreen> {
  late UserProvider userProvider;
  late UserModel? user;
  late bool isProfilePrivacy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.watch<UserProvider>().user;
    isProfilePrivacy = user?.isProfilePrivacy ?? true;
  }

  final SecureStorageService secureStorageService = SecureStorageService();
  bool _loadingCvs = false;
  bool _loadingUpload = false;
  bool _isDeleting = false;
  List<CvModel> _cvs = [];
  Map<String, dynamic> meta = {};
  int _currentPage = 1;
  int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    getMyCv(_currentPage, _pageSize, {});
  }

  Future<void> getMyCv(current, pageSize, queryParams) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;

    setState(() {
      _loadingCvs = true;
    });

    try {
      final response = await ApiService().get(
        dotenv.get('API_URL') +
            'cvs?current=$current&pageSize=$pageSize&query[user_id]=${user?.id}',
        token: await secureStorageService.getRefreshToken(),
      );

      if (response['statusCode'] == 200 && response['data'] != null) {
        final List<dynamic> cvsData = response['data']['items'];
        setState(() {
          _cvs = cvsData.map((cv) => CvModel.fromJson(cv)).toList();
          meta = response['data']['meta'];
          _currentPage = meta['current_page'] ?? 1;
        });
      }
    } catch (e) {
      print('Error fetching CVs: $e');
    } finally {
      setState(() {
        _loadingCvs = false;
      });
    }
  }

  Future<void> uploadFile(String filePath) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    String? userIdString;

    if (user?.id != null) {
      userIdString = user!.id!.toString();
    } else {
      // Handle the case where user or user.id is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy thông tin người dùng để tải lên.'),
        ),
      );
      return; // Exit the function if user info is missing
    }

    try {
      setState(() {
        _loadingUpload = true;
      });
      final response = await FileService.uploadFilePdf(filePath, userIdString!);
      print("response $response");
      if (response != null) {
        final parsedResponse = json.decode(response);
        if (parsedResponse['statusCode'] == 201 &&
            parsedResponse['data'] != null) {
          final url = parsedResponse['data']['result']['url'];
          final cvName = filePath.split('/').last;
          final resultBytes = parsedResponse['data']['result']['bytes'];
          final publicId = parsedResponse['data']['result']['public_id'];
          final responseData = await FileService.updateCvOfUser(
            url,
            resultBytes,
            cvName,
            publicId,
            user?.id ??
                '', // Fallback to empty string if user?.id is null for updateCvOfUser
          );
          print("responseData $responseData");
          if (responseData['statusCode'] == 201) {
            getMyCv(1, _pageSize, {});
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(responseData['message'])));
          }
        } else {
          print("Upload response error: $parsedResponse");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi tải lên: Phản hồi không hợp lệ.')),
          );
        }
      } else {
        print("Upload failed: No response received");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tải lên thất bại: Không nhận được phản hồi từ máy chủ.',
            ),
          ),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi trong quá trình tải lên: $e')),
      );
    } finally {
      setState(() {
        _loadingUpload = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = meta['total_pages'] ?? 1;

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
          'Thiết lập hồ sơ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ), // Set profile
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Bật cho phép tìm kiếm hồ sơ', // Enable profile search
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      CupertinoSwitch(
                        value: isProfilePrivacy,
                        onChanged: (value) {
                          // Cập nhật state ngay lập tức
                          setState(() {
                            isProfilePrivacy = value;
                          });
                          print('value $value');

                          // Sau đó mới gọi API
                          final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          final UserModel? user = userProvider.user;

                          UserServices.updateUser({
                                'is_profile_privacy': value,
                                "id": user?.id,
                              }, context: context)
                              .then((response) {
                                print('response $response');
                              })
                              .catchError((error) {
                                print('Error updating profile privacy: $error');
                                // Nếu cần, có thể revert lại state khi API lỗi
                                // setState(() {
                                //   isProfilePrivacy = !value;
                                // });
                              });
                        },
                        activeColor: Color(0xFFDA4156),
                        trackColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                  Text(
                    'Bật và cho phép nhà tuyển dụng xem hồ sơ của bạn', // Enable and allow recruiters to see your profile
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Hồ sơ ứng tuyển', // Application profile
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _loadingCvs
                      ? Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          ..._cvs.map((cv) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 4.0),
                              child: _buildResumeItem(
                                title: cv.cvName,
                                subtitle:
                                    'Đã tải lên: ${cv.createdAt.substring(0, 10)}',
                                trailing: IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 20.0,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              ListTile(
                                                leading: Icon(Icons.visibility),
                                                title: Text('Xem trước'),
                                                onTap: () {
                                                  DocxPdfViewer()
                                                      .openDocumentViewer(
                                                        context,
                                                        cv.cvLink,
                                                        cv.cvName,
                                                      );
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.download),
                                                title: Text('Tải xuống'),
                                                onTap: () async {
                                                  try {
                                                    // Launch URL in browser to download the PDF
                                                    final Uri url = Uri.parse(
                                                      cv.cvLink,
                                                    );
                                                    if (await canLaunchUrl(
                                                      url,
                                                    )) {
                                                      await launchUrl(
                                                        url,
                                                        mode:
                                                            LaunchMode
                                                                .externalApplication,
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Không thể tải xuống tệp PDF',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Lỗi: ${e.toString()}',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.delete_rounded,
                                                  color: Colors.red,
                                                ),
                                                title: Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (
                                                      BuildContext context,
                                                    ) {
                                                      return CustomNotification(
                                                        title: "Xóa hồ sơ",
                                                        content:
                                                            "Hồ sơ này sẽ bị xóa ngay lập tức. Bạn không thể hoàn tác hành động này.",
                                                        positiveButtonText:
                                                            "Đồng ý",
                                                        negativeButtonText:
                                                            "Hủy",
                                                        onPositiveButtonPressed: () async {
                                                          // Close the dialog
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                          // Close the bottom sheet
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                          setState(() {
                                                            _isDeleting = true;
                                                          });
                                                          final response =
                                                              await FileService.deleteCvOfUser(
                                                                [cv.id],
                                                              );

                                                          if (response['statusCode'] ==
                                                              400) {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  response['message'],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          if (response['statusCode'] ==
                                                              200) {
                                                            getMyCv(
                                                              1,
                                                              _pageSize,
                                                              {},
                                                            );
                                                          }
                                                          setState(() {
                                                            _isDeleting = false;
                                                          });
                                                        },
                                                        onNegativeButtonPressed:
                                                            () {
                                                              // Xử lý khi người dùng nhấn nút "Hủy"
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                            },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
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
                              ),
                            );
                          }).toList(),
                          if (_cvs.isNotEmpty && totalPages > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    onPressed:
                                        _currentPage > 1
                                            ? () {
                                              getMyCv(
                                                _currentPage - 1,
                                                _pageSize,
                                                {},
                                              );
                                            }
                                            : null,
                                    color:
                                        _currentPage > 1
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                  Text(
                                    '$_currentPage / $totalPages',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed:
                                        _currentPage < totalPages
                                            ? () {
                                              getMyCv(
                                                _currentPage + 1,
                                                _pageSize,
                                                {},
                                              );
                                            }
                                            : null,
                                    color:
                                        _currentPage < totalPages
                                            ? Colors.blue
                                            : Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                  SizedBox(height: 20),
                  CustomPaint(
                    painter: DashedBorderPainter(
                      color: AppColors.primaryColor,
                      strokeWidth: 1,
                      dashWidth: 5,
                      dashSpace: 3,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Hồ sơ từ máy của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hỗ trợ định dạng .doc, .docx, .pdf có kích thước dưới 5120 KB',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed:
                                _loadingUpload
                                    ? null
                                    : () async {
                                      String? filePath =
                                          await FileSystem.pickFile(
                                            type: FileType.custom,
                                            allowedExtensions: [
                                              'pdf',
                                              'doc',
                                              'docx',
                                            ],
                                          );

                                      if (filePath != null) {
                                        // Handle the selected file
                                        print('Selected file: $filePath');
                                        await uploadFile(filePath);
                                        // TODO: Implement file upload logic
                                      } else {
                                        // User canceled the picker
                                        print('File selection canceled');
                                      }
                                    },
                            icon:
                                _loadingUpload
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.blue,
                                      ),
                                    )
                                    : Icon(
                                      Icons.add,
                                      color: AppColors.primaryColor,
                                    ),
                            label: Text(
                              _loadingUpload
                                  ? 'Đang tải lên...'
                                  : 'Tải hồ sơ lên',
                              style: TextStyle(color: AppColors.primaryColor),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.backgroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isDeleting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumeItem({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: trailing,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path = Path();
    final dashWidth = this.dashWidth;
    final dashSpace = this.dashSpace;
    final width = size.width;
    final height = size.height;
    final radius = 8.0;

    // Top left corner
    path.moveTo(radius, 0);
    // Top line
    for (double i = radius; i < width - radius; i += dashWidth + dashSpace) {
      path.lineTo(i + dashWidth, 0);
      path.moveTo(i + dashWidth + dashSpace, 0);
    }
    // Top right corner
    path.arcToPoint(Offset(width, radius), radius: Radius.circular(radius));
    // Right line
    for (double i = radius; i < height - radius; i += dashWidth + dashSpace) {
      path.lineTo(width, i + dashWidth);
      path.moveTo(width, i + dashWidth + dashSpace);
    }
    // Bottom right corner
    path.arcToPoint(
      Offset(width - radius, height),
      radius: Radius.circular(radius),
    );
    // Bottom line
    for (double i = width - radius; i > radius; i -= dashWidth + dashSpace) {
      path.lineTo(i - dashWidth, height);
      path.moveTo(i - dashWidth - dashSpace, height);
    }
    // Bottom left corner
    path.arcToPoint(
      Offset(0, height - radius),
      radius: Radius.circular(radius),
    );
    // Left line
    for (double i = height - radius; i > radius; i -= dashWidth + dashSpace) {
      path.lineTo(0, i - dashWidth);
      path.moveTo(0, i - dashWidth - dashSpace);
    }
    // Top left corner
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashSpace != oldDelegate.dashSpace;
  }
}
