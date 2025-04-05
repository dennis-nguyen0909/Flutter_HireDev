import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hiredev/models/User.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/screens/InfoCompany/OpenJobCompany.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoCompanyScreen extends StatefulWidget {
  final String userId;
  InfoCompanyScreen({required this.userId});

  @override
  State<InfoCompanyScreen> createState() => _InfoCompanyScreenState();
}

class _InfoCompanyScreenState extends State<InfoCompanyScreen> {
  SecureStorageService secureStorageService = SecureStorageService();
  Map<String, dynamic> user = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCompanyInfo();
  }

  Future<void> getCompanyInfo() async {
    try {
      final response = await ApiService().get(
        dotenv.env['API_URL']! + 'users/${widget.userId}',
        token: await secureStorageService.getRefreshToken(),
      );
      print("duydeptrai ${response}");
      if (response['statusCode'] == 200) {
        setState(() {
          user = response['data']['items'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching company info: $e");
      setState(() {
        isLoading = false;
      });
    }
    print("minhduyso1 ${user}");
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userId);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : buildCompanyContent(),
      ),
    );
  }

  Widget buildCompanyContent() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    user['banner_company'] ??
                        'https://via.placeholder.com/500x150',
                  ),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print('Error loading banner image: $exception');
                  },
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 40,
              bottom: -40,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(
                    user['avatar_company'] ?? 'https://via.placeholder.com/76',
                    scale: 10,
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading avatar image: $exception');
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 50),
        Text(
          user['company_name'] ?? 'Company Name',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user['organization'] != null &&
                  user['organization']['industry_type'] != null
              ? user['organization']['industry_type']
              : 'Industry Type',
          style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
        ),
        SizedBox(height: 5),
        // Text(
        //   '233 lượt theo dõi',
        //   style: TextStyle(fontSize: 14, color: Colors.black54),
        // ),
        // SizedBox(height: 10),
        // ElevatedButton(
        //   onPressed: () {},
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.orange,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        //   child: Text('Theo dõi', style: TextStyle(color: Colors.white)),
        // ),
        TabBar(
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.black54,
          indicatorColor: AppColors.primaryColor,
          tabs: [Tab(text: 'Thông tin'), Tab(text: 'Việc làm đang tuyển')],
        ),
        Expanded(
          child: TabBarView(
            children: [CompanyInfoTab(user: user), OpenJobCompany(user: user)],
          ),
        ),
      ],
    );
  }
}

class CompanyInfoTab extends StatefulWidget {
  final Map<String, dynamic> user;
  CompanyInfoTab({required this.user});

  @override
  State<CompanyInfoTab> createState() => _CompanyInfoTabState();
}

class _CompanyInfoTabState extends State<CompanyInfoTab> {
  void _launchWebsite(String? link) async {
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Website không hợp lệ')));
      return;
    }

    final Uri url = Uri.parse(link);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Không thể mở $link');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        buildInfoSectionHtml('Mô tả', widget.user['description'] ?? ''),
        buildInfoSectionHtml(
          'Tầm nhìn',
          widget.user['organization'] != null
              ? widget.user['organization']['company_vision'] ?? ''
              : '',
        ),
        buildInfoSection(
          'Quy mô công ty',
          widget.user['organization'] != null
              ? widget.user['organization']['team_size'] ?? 'N/A'
              : 'N/A',
        ),
        buildInfoSection(
          'Lĩnh vực',
          widget.user['organization'] != null
              ? widget.user['organization']['industry_type'] ?? 'N/A'
              : 'N/A',
        ),
        Text(
          'Liên hệ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.public),
                SizedBox(width: 10),
                GestureDetector(
                  onTap:
                      () => _launchWebsite(
                        widget.user['organization'] != null
                            ? widget.user['organization']['company_website']
                            : null,
                      ),
                  child: Text(
                    widget.user['organization'] != null &&
                            widget.user['organization']['company_website'] !=
                                null
                        ? widget.user['organization']['company_website']
                        : 'N/A',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 10),
                Text(widget.user['phone'] ?? 'N/A'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 10),
                Text(widget.user['email'] ?? 'N/A'),
              ],
            ),
          ],
        ),
        SizedBox(height: 100),
      ],
    );
  }

  Widget buildInfoSection(String title, String content, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: isLink ? () {} : null,
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: isLink ? Colors.blue : Colors.black87,
                decoration:
                    isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoSectionHtml(String title, String htmlContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Html(
          data:
              htmlContent.isNotEmpty
                  ? htmlContent
                  : '<p>Không có thông tin</p>', // Hiển thị nội dung HTML
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
