import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/components/JobCard/JobCard.dart';

class JobScreen extends StatefulWidget {
  @override
  _StateJob createState() => _StateJob();
}

class _StateJob extends State<JobScreen> {
  final List<Job> jobs = [];
  final Map<String, dynamic> meta = {};
  Timer? _debounce;
  ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getJobs();
  }

  Future<void> getJobs([
    String query = '',
    int page = 1,
    int pageSize = 10,
  ]) async {
    if (page > totalPages || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final apiUrl =
          query.isEmpty
              ? dotenv.env['API_URL']! + "jobs?current=$page&pageSize=$pageSize"
              : dotenv.env['API_URL']! +
                  "jobs?current=$page&pageSize=$pageSize&query[keyword]=$query";

      final response = await ApiService().get(apiUrl);

      print("response: ${response['data']['items']}");
      if (response['data']['items'] != null) {
        setState(() {
          List<Job> items =
              (response['data']['items'] as List).map((item) {
                return Job.fromJson(item);
              }).toList();

          if (page == 1) {
            jobs.clear();
          }
          jobs.addAll(items);
          meta.clear();
          meta.addAll(Map<String, dynamic>.from(response['data']['meta']));

          currentPage = page;
          totalPages = response['data']['meta']['total_pages'];
        });
      }
    } catch (error) {
      print("Error: $error");
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      print("query: $query");
      currentPage = 1;
      getJobs(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (currentPage < totalPages) {
        getJobs('', currentPage + 1);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                focusColor: Colors.white,
                hoverColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child:
                jobs.isNotEmpty
                    ? ListView.builder(
                      controller: _scrollController, // Gán scroll controller
                      itemCount: jobs.length + 1, // Thêm 1 để hiển thị Loading
                      itemBuilder: (context, index) {
                        if (index == jobs.length) {
                          return isLoadingMore
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox(); // Hiển thị loading khi tải thêm
                        }
                        final job = jobs[index];
                        return JobCard(job: job);
                      },
                    )
                    : Center(child: Text("No jobs available")),
          ),
        ],
      ),
    );
  }
}
