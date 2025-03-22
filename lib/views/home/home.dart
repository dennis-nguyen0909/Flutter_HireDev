import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/screens/search/search.dart';
import 'package:hiredev/services/apiServices.dart';

class Home extends StatefulWidget {
  @override
  _StateHome createState() => _StateHome();
}

class _StateHome extends State<Home> {
  List<dynamic> jobs = [];
  dynamic meta = {
    'count': 0,
    'current_page': 0,
    'total': 0,
    'per_page': 0,
    'total_pages': 0,
  };
  String searchText = "";
  @override
  void initState() {
    super.initState();
    getJobs(); // Gọi hàm getJobs khi khởi tạo widget
  }

  Future<void> getJobs() async {
    try {
      final response = await ApiService().get(dotenv.env['API_URL']! + "jobs");
      print("responseduiydeptrai ${response['data']}");
      setState(() {
        jobs.addAll(response['data']['items']);
        meta = response['data']['meta'];
      });
      print("jobsd12313 ${jobs}");
      print("jobsd12313 ${meta}");
    } catch (e) {
      print("Error ${e}");
    }
  }

  @override
  void dispose() {
    // Hủy các subscription hoặc tác vụ ở đây nếu có
    super.dispose();
  }

  void onTapSearch() {
    print("searchText ${searchText}");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          child: TextField(
            onTap: onTapSearch,
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search job or skill...',
              hintStyle: TextStyle(color: Colors.grey),
              fillColor: Colors.white,
              filled: true, // Fill background with white color
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primaryColor,
              ), // Icon inside the input
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
              ), // Adjust padding to center the text
            ),
            style: TextStyle(color: AppColors.grayColor),
          ),
        ),
      ),
      body:
          jobs.isEmpty
              ? Center(
                child: CircularProgressIndicator(),
              ) // Hiển thị khi chưa có dữ liệu
              : ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  final company = job['user_id']['company_name'];
                  final avatar = job['user_id']['avatar_company'];
                  final city = job['city_id']['name'];
                  final district = job['district_id']['name'];
                  final title = job['title'];
                  final jobType = job['job_type']['name'];
                  final level = job['level']['name'];
                  final skills = job['skills']
                      .map((skill) => skill['name'])
                      .join(', ');
                  final expireDate = DateTime.parse(job['expire_date']);
                  final formattedExpireDate =
                      "${expireDate.day}/${expireDate.month}/${expireDate.year}";
                  final salary =
                      job['is_negotiable']
                          ? "Negotiable"
                          : "${job['type_money']['symbol']} ${job['salary_range']}";

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: (Column(children: [Row()])),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
