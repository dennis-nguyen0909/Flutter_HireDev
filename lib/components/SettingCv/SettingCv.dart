import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/SettingResume/SettingResume.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CvModel {
  final String id;
  final String userId;
  final String cvName;
  final String cvLink;
  final String publicId;
  final int bytes;
  final String createdAt;
  final String updatedAt;

  CvModel({
    required this.id,
    required this.userId,
    required this.cvName,
    required this.cvLink,
    required this.publicId,
    required this.bytes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['_id'],
      userId: json['user_id'],
      cvName: json['cv_name'],
      cvLink: json['cv_link'],
      publicId: json['public_id'],
      bytes: json['bytes'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class SettingCv extends StatefulWidget {
  @override
  _SettingCvState createState() => _SettingCvState();
}

class _SettingCvState extends State<SettingCv> {
  int _profileCompletion = 0;
  final SecureStorageService secureStorageService = SecureStorageService();
  bool _isLoading = false;
  List<CvModel> _cvs = [];
  bool _loadingCvs = false;
  Map<String, dynamic> meta = {};

  @override
  void initState() {
    super.initState();
    profileCompletion();
    getMyCv(1, 10, {});
  }

  Future<void> profileCompletion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
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

      print(response);

      if (response['statusCode'] == 200 && response['data'] != null) {
        final List<dynamic> cvsData = response['data']['items'];
        setState(() {
          _cvs = cvsData.map((cv) => CvModel.fromJson(cv)).toList();
          meta = response['data']['meta'];
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Text(
            'Thiết lập hồ sơ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: _buildListTile(
            title: 'Bật cho phép tìm kiếm hồ sơ',
            trailing: Switch(
              value: true, // Thay đổi giá trị tùy theo trạng thái
              onChanged: (value) {
                // Xử lý sự kiện thay đổi trạng thái
              },
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: _buildListTile(
            title: 'Bật và cho phép nhà tuyển dụng xem hồ sơ của bạn',
            trailing: Switch(
              value: true, // Thay đổi giá trị tùy theo trạng thái
              onChanged: (value) {
                // Xử lý sự kiện thay đổi trạng thái
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Hồ sơ ứng tuyển',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: _buildResumeItem(
            title: 'Hồ sơ HireDev',
            subtitle:
                '${_isLoading ? 'Đang tải...' : 'Hoàn thiện: $_profileCompletion%'}',
          ),
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
                      subtitle: 'Đã tải lên: ${cv.createdAt.substring(0, 10)}',
                      trailing: IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.visibility),
                                      title: Text('Xem trước'),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => Scaffold(
                                                  appBar: AppBar(
                                                    title: Text(
                                                      'Xem chi tiết',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    flexibleSpace: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Color(0xFFDA4156),
                                                            Colors.black,
                                                          ],
                                                          begin:
                                                              Alignment
                                                                  .topCenter,
                                                          end:
                                                              Alignment
                                                                  .bottomCenter,
                                                        ),
                                                      ),
                                                    ),
                                                    leading: IconButton(
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                  body: PDF().fromUrl(
                                                    cv.cvLink,
                                                    placeholder:
                                                        (progress) => Center(
                                                          child: Text(
                                                            '$progress %',
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (error) => Center(
                                                          child: Text(
                                                            error.toString(),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.download),
                                      title: Text('Tải xuống'),
                                      onTap: () async {
                                        try {
                                          // Launch URL in browser to download the PDF
                                          final Uri url = Uri.parse(cv.cvLink);
                                          if (await canLaunchUrl(url)) {
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
                if (meta['current'] != null &&
                    meta['pageCount'] != null &&
                    meta['current'] < meta['pageCount'])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed:
                          _loadingCvs
                              ? null
                              : () {
                                if (meta['current'] < meta['pageCount']) {
                                  getMyCv(
                                    meta['current'] + 1,
                                    meta['pageSize'],
                                    {},
                                  );
                                }
                              },
                      child:
                          _loadingCvs
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Tải thêm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDA4156),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResumeSettingsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                'Thiết lập hồ sơ',
                style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({required String title, Widget? trailing}) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 14)),
      trailing: trailing,
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
