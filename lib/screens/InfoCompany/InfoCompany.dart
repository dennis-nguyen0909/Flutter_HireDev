import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hiredev/models/User.dart';
import 'package:hiredev/models/UserMode.dart';
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
  @override
  void initState() {
    super.initState();
    getCompanyInfo();
  }

  Future<void> getCompanyInfo() async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! + 'users/${widget.userId}',
      token: await secureStorageService.getRefreshToken(),
    );
    print("duydeptrai ${response}");
    if (response['statusCode'] == 200) {
      setState(() {
        user = response['data']['items'];
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
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(user['banner_company']),
                      fit: BoxFit.cover,
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
                        user['avatar_company'],
                        scale: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              user['company_name'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user['organization']['industry_type'],
              style: TextStyle(fontSize: 16, color: Colors.blue),
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
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              tabs: [Tab(text: 'Thông tin'), Tab(text: 'Việc làm đang tuyển')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CompanyInfoTab(user: user),
                  OpenJobCompany(user: user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyInfoTab extends StatelessWidget {
  final Map<String, dynamic> user;
  CompanyInfoTab({required this.user});

  void _launchWebsite(String link) async {
    final Uri url = Uri.parse(link);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception(
        'Không thể mở ${user['organization']['company_website']}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String htmlDescription = "<body>${user['description']}</body>";
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        buildInfoSectionHtml('Mô tả', user['description']),
        buildInfoSectionHtml(
          'Tầm nhìn',
          user['organization']['company_vision'],
        ),
        buildInfoSection('Quy mô công ty', user['organization']['team_size']),
        buildInfoSection('Lĩnh vực', user['organization']['industry_type']),
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
                        user['organization']['company_website'],
                      ),
                  child: Text(user['organization']['company_website']),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 10),
                Text(user['phone']),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.email),
                SizedBox(width: 10),
                Text(user['email']),
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
          data: htmlContent, // Hiển thị nội dung HTML
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
