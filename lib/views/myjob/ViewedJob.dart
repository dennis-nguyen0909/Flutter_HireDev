import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/jobDetail/JobDetail.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:hiredev/views/myjob/JobCard.dart';
import 'package:provider/provider.dart';

class ViewedJob extends StatefulWidget {
  @override
  _ViewedJobState createState() => _ViewedJobState();
}

class _ViewedJobState extends State<ViewedJob> {
  final SecureStorageService secureStorageService = SecureStorageService();
  List<dynamic> recentViewedJobs = [];
  Map<String, dynamic> meta = {};
  bool isLoading = false;
  int currentPage = 1;
  final int pageSize = 10;
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getRecentViewedJob(currentPage, pageSize, {});
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
      if (!isLoadingMore && currentPage < (meta['totalPages'] ?? 1)) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    await getRecentViewedJob(currentPage + 1, pageSize, {}, loadMore: true);

    setState(() {
      isLoadingMore = false;
      currentPage += 1;
    });
  }

  Future<void> getRecentViewedJob(
    current,
    pageSize,
    queryParams, {
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

      final query = {
        'current': current,
        'pageSize': pageSize,
        'queryParams': queryParams,
      };
      final response = await ApiService().get(
        dotenv.env['API_URL']! +
            'users/get-viewed-jobs/${user?.id}?current=$current&pageSize=$pageSize',
        token: await secureStorageService.getRefreshToken(),
      );

      if (response['statusCode'] == 200) {
        setState(() {
          if (loadMore) {
            recentViewedJobs.addAll(response['data']['items']);
          } else {
            recentViewedJobs = response['data']['items'];
          }
          meta = response['data']['meta'];
        });
      }
    } catch (e) {
      print("Error: ${e}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      currentPage = 1;
    });
    await getRecentViewedJob(1, pageSize, {});
  }

  Widget _buildJobCard(dynamic job) {
    print("duydeptraijo1b ${job}");
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: const Color.fromARGB(255, 253, 249, 249)),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  job['user_id']?['avatar_company'] ??
                      'https://via.placeholder.com/50',
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job['company_name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              job['title'] ?? '',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              job['skill_name'] != null ? job['skill_name'].join(', ') : '',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : recentViewedJobs.isEmpty
              ? Center(child: Text('Không có dữ liệu'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(10),
                      itemCount:
                          recentViewedJobs.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == recentViewedJobs.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        print("duydeptraijob ${recentViewedJobs[index]}");
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => JobDetailScreen(
                                      id: recentViewedJobs[index]['_id'],
                                      title: recentViewedJobs[index]['title'],
                                    ),
                              ),
                            );
                          },
                          child: _buildJobCard(recentViewedJobs[index]),
                        );
                      },
                    ),
                  ),
                  if (meta['totalPages'] != null &&
                      currentPage < meta['totalPages'] &&
                      !isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Kéo xuống để tải thêm',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  if (meta['totalPages'] != null &&
                      currentPage == meta['totalPages'] &&
                      recentViewedJobs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Đã hiển thị tất cả ${meta['totalItems'] ?? recentViewedJobs.length} công việc',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
    );
  }
}
