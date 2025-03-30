import 'package:flutter/material.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/views/account/account.dart';
import 'package:hiredev/views/company/company.dart';
import 'package:hiredev/views/home/home.dart';
import 'package:hiredev/views/job/job.dart';
import 'package:hiredev/views/myjob/MyJobScreen.dart';
import 'package:provider/provider.dart';

class AppMainScreen extends StatefulWidget {
  @override
  _StateAppMainScreen createState() => _StateAppMainScreen();
}

class _StateAppMainScreen extends State<AppMainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late List<BottomNavigationBarItem> _navigationItems;

  @override
  void initState() {
    super.initState();
    _screens = <Widget>[
      HomeScreen(),
      MyJobScreen(),
      JobScreen(),
      Company(),
      Account(),
    ];

    _navigationItems = const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Job"),
      BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
      BottomNavigationBarItem(icon: Icon(Icons.business), label: "Companies"),
      BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: "Account"),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.user;
    print('user: ${user?.roleName}');

    // Nếu roleName là EMPLOYER, chỉ hiện 2 tab là HOME và ACCOUNT
    List<Widget> activeScreens = _screens;
    List<BottomNavigationBarItem> activeItems = _navigationItems;

    if (user?.roleName == 'EMPLOYER') {
      activeScreens = [HomeScreen(), Account()];
      activeItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: "Account"),
      ];

      // Đảm bảo selectedIndex không vượt quá số lượng tab
      if (_selectedIndex >= activeScreens.length) {
        _selectedIndex = 0;
      }
    }

    return Scaffold(
      body: Center(child: activeScreens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: activeItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFDA4156),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
