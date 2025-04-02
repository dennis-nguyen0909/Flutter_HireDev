import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/JobCard/JobCard.dart';
import 'package:hiredev/models/job.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class OpenJobCompany extends StatefulWidget {
  final Map<String, dynamic> user;
  OpenJobCompany({required this.user});

  @override
  State<OpenJobCompany> createState() => _OpenJobCompanyState();
}

class _OpenJobCompanyState extends State<OpenJobCompany> {
  List<Job> jobs = [];
  Map<String, dynamic> meta = {};
  SecureStorageService secureStorageService = SecureStorageService();

  int currentPage = 1;
  final int pageSize = 10;
  bool isLoading = false;
  bool hasMore = true;

  late ScrollController _scrollController;

  // Filter State
  String searchQuery = "";
  String sortBy = "-createdAt"; // newest, oldest
  String jobType = "All"; // Full-time, Part-time, Contract
  String contractType = "All"; // Permanent, Temporary

  final List<String> jobTypes = ["All", "Full-time", "Part-time", "Contract"];
  final List<String> contractTypes = ["All", "Permanent", "Temporary"];
  final List<Map<String, String>> sortOptions = [
    {"value": "-createdAt", "label": "Mới nhất"},
    {"value": "createdAt", "label": "Cũ nhất"},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    getJobs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getJobs({bool reset = false}) async {
    if (isLoading || (!reset && !hasMore)) return;

    if (reset) {
      setState(() {
        jobs.clear();
        currentPage = 1;
        hasMore = true;
      });
    }

    setState(() {
      isLoading = true;
    });

    String queryParams =
        "query[user_id]=${widget.user['_id']}&query[sort]=$sortBy";

    if (searchQuery.isNotEmpty) queryParams += "&query[keyword]=$searchQuery";
    if (jobType != "All") queryParams += "&query[job_type]=$jobType";
    if (contractType != "All")
      queryParams += "&query[job_contract_type]=$contractType";

    final response = await ApiService().get(
      dotenv.get('API_URL') +
          'jobs?current=$currentPage&pageSize=$pageSize&$queryParams',
      token: await secureStorageService.getRefreshToken(),
    );

    if (response['statusCode'] == 200) {
      List<Job> items =
          (response['data']['items'] as List)
              .map((item) => Job.fromJson(item))
              .toList();

      setState(() {
        jobs.addAll(items);
        meta = Map<String, dynamic>.from(response['data']['meta']);

        hasMore = items.length == pageSize;
        if (hasMore) {
          currentPage++;
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      getJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bộ lọc
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Ô tìm kiếm
              TextField(
                decoration: InputDecoration(
                  hintText: "Tìm kiếm công việc...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  searchQuery = value;
                  getJobs(reset: true);
                },
              ),
              SizedBox(height: 8),

              // Dropdown: Sắp xếp & Loại công việc & Loại hợp đồng
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: sortBy,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items:
                          sortOptions.map((option) {
                            return DropdownMenuItem(
                              value: option["value"],
                              child: Text(option["label"]!),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          sortBy = value!;
                          getJobs(reset: true);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: jobType,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items:
                          jobTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          jobType = value!;
                          getJobs(reset: true);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          contractTypes.contains(contractType)
                              ? contractType
                              : contractTypes[0], // Kiểm tra giá trị hợp lệ
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items:
                          contractTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          contractType = value!;
                          getJobs(reset: true);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Hiển thị tổng số công việc
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Việc làm đang tuyển:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text(
                "(" + meta['total'].toString() + " việc làm)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // Danh sách công việc
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: jobs.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < jobs.length) {
                return Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: JobCard(job: jobs[index], isDisplayHeart: false),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
