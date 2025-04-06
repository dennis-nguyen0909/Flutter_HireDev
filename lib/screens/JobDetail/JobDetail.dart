import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/Output/OutputInfoJob.dart';
import 'package:hiredev/models/JobDetail.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/screens/ApplyJob/ApplyJob.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/currency.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class JobDetailScreen extends StatefulWidget {
  final String id;
  final String title;

  JobDetailScreen({required this.id, required this.title});

  @override
  State<StatefulWidget> createState() => JobDetailScreenState();
}

class JobDetailScreenState extends State<JobDetailScreen> {
  Jobdetail? job;
  bool isLoading = true;
  bool isFavorite = false;
  final SecureStorageService secureStorageService = SecureStorageService();
  @override
  void initState() {
    super.initState();
    getJobDetail();
    getDetailFavorite();
  }

  Future<void> getJobDetail() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    final response = await ApiService().get(
      dotenv.env['API_URL']! + "jobs/${widget.id}/${user!.id}",
    );
    if (response['statusCode'] == 200) {
      print(response['data']);
      setState(() {
        job = Jobdetail.fromJson(response['data']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> favoriteJob() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    String? token = await secureStorageService.getRefreshToken();
    final response = await ApiService()
        .post(dotenv.env['API_URL']! + "favorite-jobs", {
          'jobTitle': widget.title.toString(),
          'job_id': widget.id.toString(),
          'user_id': user!.id.toString(),
        }, token: token);
    if (response['statusCode'] == 201) {
      if (response['data'].length == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã hủy yêu thích')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm vào danh sách yêu thích')),
        );
      }
      getDetailFavorite();
    }

    if (response['statusCode'] == 400) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${response['message']}")));
    }
    if (response['status'] == 419) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${response['message']}")));
    }
  }

  Future<void> getDetailFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    String? token = await secureStorageService.getRefreshToken();
    final response = await ApiService().get(
      dotenv.env['API_URL']! +
          "favorite-jobs/get-detail?user_id=${user!.id}&job_id=${widget.id}",
      token: token,
    );
    if (response['statusCode'] == 200) {
      setState(() {
        isFavorite = true;
      });
    }
    if (response['response']['statusCode'] == 404) {
      setState(() {
        isFavorite = false;
      });
    }
  }

  Future<void> applyJob() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    String? token = await secureStorageService.getRefreshToken();
    final response = await ApiService().post(
      dotenv.env['API_URL']! + "apply-jobs",
      {'job_id': widget.id.toString(), 'user_id': user!.id.toString()},
      token: token,
    );
    if (response['statusCode'] == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã ứng tuyển')));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  // Background and header
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 250, // Set height for header
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFDA4156), Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 50.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            SizedBox(height: 16),
                            Text(
                              job!.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      job!.user.companyName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          job!.city.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(job!.expireDate),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Image.network(
                                    job!.user.avatarCompany,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 250, // Push content below the header
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Job Description Section
                                  Text(
                                    "Mô tả công việc",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...job!.profesionalSkills
                                      .map(
                                        (professionalSkill) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Render title
                                            Text(
                                              professionalSkill.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 8),

                                            // Render từng skill trong danh sách items
                                            ...professionalSkill.items
                                                .map(
                                                  (skill) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 4.0,
                                                        ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 6.0,
                                                              ),
                                                          child: Container(
                                                            width: 6,
                                                            height: 6,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            skill,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ],
                                        ),
                                      )
                                      .toList(),

                                  SizedBox(height: 20),

                                  // Skills Section
                                  Text(
                                    "Kỹ năng",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        job!.skills
                                            .map(
                                              (skill) => Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEEF2FF),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Color(0xFFD1D5DB),
                                                  ),
                                                ),
                                                child: Text(
                                                  skill
                                                      .name, // Render tên của skill từ API
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF4F46E5),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),

                                  SizedBox(height: 20),

                                  // General Requirements Section
                                  Text(
                                    "Yêu cầu chung",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...job!.generalRequirements.map(
                                    (req) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              req.requirement,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Job Responsibilities Section
                                  Text(
                                    "Trách nhiệm công việc",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...job!.jobResponsibilities
                                      .map(
                                        (resp) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6.0,
                                                ),
                                                child: Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black87,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  resp.responsibility,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),

                                  SizedBox(height: 20),

                                  // Interview Process Section
                                  Text(
                                    "Quy trình phỏng vấn",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...job!.interviewProcess.map(
                                    (process) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              process.process,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),

                                  // Benefits Section
                                  Text(
                                    "Phúc lợi",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ...job!.benefits
                                      .map(
                                        (benefit) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF4F46E5),
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  benefit.benefit,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  SizedBox(height: 20),
                                  Text(
                                    "Địa điểm làm việc",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        double
                                            .infinity, // Đảm bảo chiều rộng là hết cỡ
                                    child: Card(
                                      color: Color(0xFFCCCCCC),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 0.5,
                                          //
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          10,
                                        ), // Khoảng cách bên trong Card
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_off_outlined),
                                            SizedBox(width: 10),
                                            Text(
                                              job!.district.name +
                                                  ", " +
                                                  job!.city.name,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Company Info Section
                                  Text(
                                    "Thông tin công ty",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                    ),
                                    shadowColor: Colors.grey.shade300,
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Image.network(
                                                job!.user.avatarCompany,
                                                width: 60,
                                                height: 60,
                                              ),
                                              SizedBox(width: 30),
                                              Text(
                                                job!.user.companyName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Color(
                                                      0xFFCCCCCC,
                                                    ),

                                                    side: BorderSide.none,
                                                    shadowColor:
                                                        Colors.transparent,

                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  child: Text(
                                                    "Xem việc làm khác",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    "Thông tin công việc",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      OutputInfoJob(
                                        title: "Số lượng tuyển",
                                        value: job!.countApply.toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Hạn nộp hồ sơ",
                                        value: job!.expireDate.toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Đăng ngày",
                                        value: job!.postedDate.toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Loại công việc",
                                        value:
                                            job!.jobContractType.name
                                                .toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Lương",
                                        value:
                                            job!.isNegotiable
                                                ? "Thương lượng"
                                                : Currency.formatCurrencyWithSymbol(
                                                      job!.salaryRangeMin
                                                          .toInt(),
                                                      job!.typeMoney.code,
                                                    ) +
                                                    " - " +
                                                    Currency.formatCurrencyWithSymbol(
                                                      job!.salaryRangeMax
                                                          .toInt(),
                                                      job!.typeMoney.code,
                                                    ),
                                      ),
                                      OutputInfoJob(
                                        title: "Cấp bậc",
                                        value: job!.level.name.toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Làm việc tại",
                                        value: job!.jobType.name.toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Kinh nghiệm tối thiểu",
                                        value: job!.minExperience.toString(),
                                      ),
                                      OutputInfoJob(
                                        title: "Bằng cấp",
                                        value: job!.degree.name.toString(),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 300,
                                  ), // Extra space for bottom padding
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    job!.candidateIds.contains(user!.id) ||
                                            job!.expireDate.isBefore(
                                              DateTime.now(),
                                            )
                                        ? const Color.fromARGB(
                                          255,
                                          200,
                                          193,
                                          193,
                                        )
                                        : Color(0xFFFF5A5F),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                if (job!.candidateIds.contains(user!.id)) {
                                  return;
                                }
                                if (job!.expireDate.isBefore(DateTime.now())) {
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ApplyJob(
                                          jobId: job!.id,
                                          employerId: job!.user.id,
                                          jobTitle: job!.title,
                                          jobImage: job!.user.avatarCompany,
                                          companyName: job!.user.companyName,
                                          isNegotiable:
                                              job!.isNegotiable.toString(),
                                          city: job!.city.name,
                                          district: job!.district.name,
                                          salaryType: job!.salaryType,
                                          typeMoney: job!.typeMoney.code,
                                          salaryRangeMax: job!.salaryRangeMax,
                                          salaryRangeMin: job!.salaryRangeMin,
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                job!.candidateIds.contains(user!.id)
                                    ? "Đã ứng tuyển"
                                    : job!.expireDate.isBefore(DateTime.now())
                                    ? "Hết hạn"
                                    : "Ứng Tuyển",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              favoriteJob();
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 24,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              size: 24,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
