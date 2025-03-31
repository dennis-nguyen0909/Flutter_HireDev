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

  @override
  void initState() {
    super.initState();
    getRecentAppliedJob(1, 10, {});
  }

  Future<void> getRecentAppliedJob(current, pageSize, queryParams) async {
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
            'applications/recently-applied-candidate?current=$current&pageSize=$pageSize&query[user_id]=${user?.id}',
        token: await secureStorageService.getRefreshToken(),
      );
      print("duydeptrai ${response['data']['items']}");
      if (response['statusCode'] == 200) {
        setState(() {
          appliedJobs = response['data']['items'];
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
    return RefreshIndicator(
      onRefresh: () async {
        await getRecentAppliedJob(1, 10, {});
      },
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : appliedJobs.length == 0
              ? Center(child: Text('Không có dữ liệu'))
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: appliedJobs.length,
                itemBuilder: (context, index) {
                  return JobCard(appliedJobs[index], true);
                },
              ),
    );
  }
}
