import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';

class SearchScreen extends StatefulWidget {
  @override
  _StateSearchScreen createState() => _StateSearchScreen();
}

class _StateSearchScreen extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search job or skill...",
              hintStyle: TextStyle(color: Color(0xFF808080)),
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(
                Icons.search_sharp,
                color: AppColors.grayColor,
                size: 30,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
    );
  }
}
