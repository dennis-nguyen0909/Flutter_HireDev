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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getRecentSavedJob(1, 10, {});
  }

  Future<void> getRecentSavedJob(current, pageSize, queryParams) async {
    try {
      setState(() {
        isLoading = true;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final UserModel? user = userProvider.user;

      final query = {
        'current': current,
        'pageSize': pageSize,
        'queryParams': queryParams,
      };
      final response = await ApiService().get(
        dotenv.env['API_URL']! +
            'favorite-jobs?current=$current&pageSize=$pageSize&query[user_id]=${user?.id}',
        token: await secureStorageService.getRefreshToken(),
      );
      print("duydeptrai ${response['data']['items']}");
      if (response['statusCode'] == 200) {
        setState(() {
          savedJobs = response['data']['items'];
        });
      }
    } catch (e) {
      print("duydeptrai ${e}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("savedJobs[index]['job_id'] ${savedJobs[0]['job_id']}");
    return RefreshIndicator(
      onRefresh: () async {
        await getRecentSavedJob(1, 10, {});
      },
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : savedJobs.length == 0
              ? Center(child: Text('Không có dữ liệu'))
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: savedJobs.length,
                itemBuilder: (context, index) {
                  return JobCard(job: savedJobs[index]['job_id']);
                },
              ),
    );
  }
}
