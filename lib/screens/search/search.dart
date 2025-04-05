import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/JobCard/JobCard.dart';
import 'package:hiredev/models/Location.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/screens/Location/Location.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  SecureStorageService secureStorageService = SecureStorageService();
  List<Job> _jobs = [];
  Map<String, dynamic> _meta = {};
  ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _pageSize = 10;
  bool _isLoading = false;
  Timer? _debounceTimer;
  dynamic selectedLocation;
  @override
  void initState() {
    super.initState();
    getJob(_currentPage, _pageSize, {});

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoading && _meta['currentPage'] < _meta['totalPages']) {
          setState(() {
            _currentPage++;
            _isLoading = true;
          });
          getJob(_currentPage, _pageSize, {});
        }
      }
    });
  }

  Future<void> getJob(current, pageSize, queryParams) async {
    String cityIdParam = '';
    if (selectedLocation != null && selectedLocation['id'] != null) {
      cityIdParam = '&query[city_id]=${selectedLocation['id']}';
    }

    final queryParams =
        'current=$current&pageSize=$pageSize&query[keyword]=${_searchController.text}$cityIdParam';
    final response = await ApiService().get(
      dotenv.env['API_URL']! + 'jobs?$queryParams',
      token: await secureStorageService.getRefreshToken(),
    );
    print(dotenv.env['API_URL']! + 'jobs?$queryParams');
    if (response['statusCode'] == 200) {
      List<Job> items =
          (response['data']['items'] as List).map((item) {
            return Job.fromJson(item);
          }).toList();
      setState(() {
        _jobs = items;
        _meta = response['data']['meta'];
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _jobs.clear();
      });
      getJob(1, _pageSize, {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged, // Handle search input changes
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _jobs.clear();
                });
                getJob(1, _pageSize, {});
              },
            ),
          ),
          style: TextStyle(color: Colors.black, fontSize: 14.0),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Chip(label: Text('Java')),
                SizedBox(width: 8.0),
                Chip(label: Text('Api Testing')),
                SizedBox(width: 8.0),
                Chip(label: Text('Golang')),
                SizedBox(width: 8.0),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationScreen()),
                    );
                    setState(() {
                      selectedLocation = result;
                      // Call getJob again when location is selected
                      if (selectedLocation != null) {
                        _jobs.clear();
                        _currentPage = 1;
                        getJob(_currentPage, _pageSize, {});
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Colors.grey),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('Địa điểm', style: TextStyle(color: Colors.black)),
                      SizedBox(width: 4.0),
                      Icon(Icons.location_on, size: 16.0),
                    ],
                  ),
                ),
                SizedBox(width: 12.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text('Ngành nghề', style: TextStyle(color: Colors.black)),
                      SizedBox(width: 4.0),
                      Icon(Icons.work, size: 16.0),
                    ],
                  ),
                ),
                SizedBox(width: 12.0),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Lĩnh vực công ty',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(width: 4.0),
                      Icon(Icons.business, size: 16.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _jobs.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _jobs.length) {
                  return Center(child: CircularProgressIndicator());
                }
                return JobCard(job: _jobs[index], isDisplayHeart: false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
