import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/myjob/JobCard.dart';
import 'package:provider/provider.dart';

class AppliedJob extends StatefulWidget {
  @override
  _AppliedJobState createState() => _AppliedJobState();
}

class _AppliedJobState extends State<AppliedJob> {
  final SecureStorageService secureStorageService = SecureStorageService();
  List<dynamic> appliedJobs = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  Map<String, dynamic> meta = {};
  int currentPage = 1;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getRecentAppliedJob(currentPage, pageSize, {});
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoadingMore && currentPage < (meta['totalPages'] ?? 0)) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    await getRecentAppliedJob(currentPage + 1, pageSize, {}, loadMore: true);
  }

  Future<void> getRecentAppliedJob(
    int current,
    int pageSize,
    Map<String, dynamic> queryParams, {
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        setState(() {
          isLoading = true;
        });
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final UserModel? user = userProvider.user;

      final response = await ApiService().get(
        dotenv.env['API_URL']! +
            'applications/recently-applied-candidate?current=$current&pageSize=$pageSize&query[user_id]=${user?.id}',
        token: await secureStorageService.getRefreshToken(),
      );

      print("duydeptrai ${response['data']['items']}");
      if (response['statusCode'] == 200) {
        setState(() {
          if (loadMore) {
            appliedJobs.addAll(response['data']['items']);
          } else {
            appliedJobs = response['data']['items'];
          }
          meta = response['data']['meta'];
          currentPage = current;
        });
      }
    } catch (e) {
      print("duydeptrai ${e}");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        currentPage = 1;
        await getRecentAppliedJob(1, pageSize, {});
      },
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : appliedJobs.isEmpty
              ? Center(child: Text('Không có dữ liệu'))
              : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(10),
                itemCount: appliedJobs.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == appliedJobs.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return JobCard(appliedJobs[index], true);
                },
              ),
    );
  }
}
