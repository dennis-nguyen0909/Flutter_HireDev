import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MyJobScreen());
  }
}

class MyJobScreen extends StatelessWidget {
  final List<Map<String, String>> jobs = [
    {
      'company': 'Netcompany',
      'position': 'Software Developer (Fresher and Junior)',
      'salary': 'Thương lượng',
      'location': 'Hồ Chí Minh',
    },
    {
      'company': 'LR-TEK',
      'position': 'Front-End Developer',
      'salary': 'Thương lượng',
      'location': 'Hồ Chí Minh',
    },
    {
      'company': 'CIGRO VIETNAM',
      'position': 'Full-Stack Developer',
      'salary': 'Thương lượng',
      'location': 'Hồ Chí Minh',
    },
    {
      'company': 'Âm Nhạc Swee Lee',
      'position': 'Web Developer (Shopify)',
      'salary': 'Thương lượng',
      'location': 'Hồ Chí Minh',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
            'Việc của tôi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.blue,
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Đã ứng tuyển'),
                    Tab(text: 'Đã lưu'),
                    Tab(text: 'Đã xem'),
                    Tab(text: 'Lời mời ứng tuyển'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return JobCard(jobs[index]);
              },
            ),
            Center(child: Text('Đã lưu')),
            Center(child: Text('Đã xem')),
            Center(child: Text('Lời mời ứng tuyển')),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Map<String, String> job;

  JobCard(this.job);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job['company']!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(job['position']!, style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text(
              job['salary']!,
              style: TextStyle(color: Colors.orange, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              job['location']!,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 6),
            Text(
              'Hồ sơ đã gửi tới Nhà tuyển dụng',
              style: TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
