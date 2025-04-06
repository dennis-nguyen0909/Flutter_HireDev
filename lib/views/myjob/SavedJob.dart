import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/JobCard/JobCard.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class SavedJob extends StatefulWidget {
  @override
  _SavedJobState createState() => _SavedJobState();
}

class _SavedJobState extends State<SavedJob> {
  final SecureStorageService secureStorageService = SecureStorageService();
  List<dynamic> savedJobs = [];
  Map<String, dynamic> meta = {};
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getRecentSavedJob(currentPage, pageSize, {});
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

    await getRecentSavedJob(currentPage + 1, pageSize, {}, loadMore: true);
  }

  Future<void> getRecentSavedJob(
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
            'favorite-jobs?current=$current&pageSize=$pageSize&query[user_id]=${user?.id}',
        token: await secureStorageService.getRefreshToken(),
      );

      if (response['statusCode'] == 200) {
        setState(() {
          if (loadMore) {
            savedJobs.addAll(response['data']['items']);
          } else {
            savedJobs = response['data']['items'];
          }
          meta = response['data']['meta'];
          currentPage = current;
        });
      }
    } catch (e) {
      print("error ${e}");
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
        await getRecentSavedJob(1, pageSize, {});
      },
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : savedJobs.isEmpty
              ? Center(child: Text('Không có dữ liệu'))
              : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(10),
                itemCount: savedJobs.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == savedJobs.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return JobCard(
                    job: savedJobs[index]!['job_id'],
                    isFavorite: true,
                    isDisplayHeart: false,
                  );
                },
              ),
    );
  }
}
