import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/SettingCv/SettingCv.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResumeSettingsScreen extends StatefulWidget {
  @override
  _ResumeSettingsScreenState createState() => _ResumeSettingsScreenState();
}

class _ResumeSettingsScreenState extends State<ResumeSettingsScreen> {
  bool _allowSearch = true;
  final SecureStorageService secureStorageService = SecureStorageService();
  bool _loadingCvs = false;
  List<CvModel> _cvs = [];
  Map<String, dynamic> meta = {};

  @override
  void initState() {
    super.initState();
    getMyCv(1, 10, {});
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
    print(_cvs);
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
      body: SingleChildScrollView(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _allowSearch,
                    onChanged: (value) {
                      setState(() {
                        _allowSearch = value;
                      });
                    },
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
                                                            Alignment.topCenter,
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
                                                LaunchMode.externalApplication,
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
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
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
                      onPressed: () {
                        // Implement upload resume logic here
                      },
                      icon: Icon(Icons.add, color: Colors.blue),
                      label: Text(
                        'Tải hồ sơ lên',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
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
            ],
          ),
        ),
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
