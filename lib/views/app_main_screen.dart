import 'package:flutter/material.dart';
import 'package:hiredev/views/account/account.dart';
import 'package:hiredev/views/company/company.dart';
import 'package:hiredev/views/home/home.dart';
import 'package:hiredev/views/job/job.dart';

class AppMainScreen extends StatefulWidget {
  @override
  _StateAppMainScreen createState() => _StateAppMainScreen();
}

class _StateAppMainScreen extends State<AppMainScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = <Widget>[
    Home(),
    JobScreen(),
    Company(),
    Account(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(child: _screens[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: "Companies",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: "Account",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFDA4156),
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
