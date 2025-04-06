import 'package:flutter/material.dart';
import 'package:hiredev/views/myjob/AppliedJob.dart';
import 'package:hiredev/views/myjob/SavedJob.dart';
import 'package:hiredev/views/myjob/ViewedJob.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: MyJobScreen(),
    );
  }
}

class MyJobScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
            AppliedJob(),
            SavedJob(),
            ViewedJob(),
            Center(child: Text('Lời mời ứng tuyển')),
          ],
        ),
      ),
    );
  }
}
