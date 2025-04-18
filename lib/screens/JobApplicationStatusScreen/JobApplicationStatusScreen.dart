import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/currency.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:intl/intl.dart';

class JobApplicationStatusScreen extends StatefulWidget {
  final Map<dynamic, dynamic> appliedJob;
  JobApplicationStatusScreen({required this.appliedJob});
  @override
  _JobApplicationStatusScreenState createState() =>
      _JobApplicationStatusScreenState();
}

class _JobApplicationStatusScreenState
    extends State<JobApplicationStatusScreen> {
  final SecureStorageService secureStorageService = SecureStorageService();
  Map<String, dynamic> jobApplicationStatus = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getJobApplicationStatus();
  }

  Future<void> getJobApplicationStatus() async {
    try {
      print("widget.appliedJob: ${widget.appliedJob}");
      print(widget.appliedJob['_id']);
      final response = await ApiService().get(
        '${dotenv.env['API_URL']}applications/${widget.appliedJob['_id']}',
        token: await secureStorageService.getRefreshToken(),
      );
      if (response['statusCode'] == 200) {
        setState(() {
          jobApplicationStatus = response['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching job application status: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trạng thái ứng tuyển',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDA4156), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin công việc
                    Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                widget.appliedJob['employer_id']?['avatar_company'] ??
                                    widget
                                        .appliedJob['job_id']?['user_id']?['avatar_company'] ??
                                    'https://via.placeholder.com/50', // Ảnh mặc định
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.appliedJob['employer_id']?['company_name'] ??
                                    widget
                                        .appliedJob['job_id']?['user_id']?['company_name'] ??
                                    '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.appliedJob['job_id']?['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          widget.appliedJob['job_id']?['is_negotiable'] ==
                                  'true'
                              ? Text(
                                'Thỏa thuận',
                                style: TextStyle(fontSize: 14),
                              )
                              : Text(
                                Currency.formatCurrencyWithSymbol(
                                      int.tryParse(
                                            widget.appliedJob['job_id']?['salary_range_min']
                                                    ?.toString() ??
                                                '',
                                          ) ??
                                          0,
                                      widget.appliedJob['job_id']?['type_money']?['symbol'] ??
                                          '',
                                    ) +
                                    " - " +
                                    Currency.formatCurrencyWithSymbol(
                                      int.tryParse(
                                            widget.appliedJob['job_id']?['salary_range_max']
                                                    ?.toString() ??
                                                '',
                                          ) ??
                                          0,
                                      widget.appliedJob['job_id']?['type_money']?['symbol'] ??
                                          '',
                                    ),
                                style: TextStyle(fontSize: 14),
                              ),
                          SizedBox(height: 4),
                          Text(
                            widget.appliedJob['job_id']?['city_id']?['name'] ??
                                '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    // Trạng thái ứng tuyển
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 12),
                              SizedBox(width: 8),
                              Text(
                                jobApplicationStatus['applied_date'] != null
                                    ? DateFormat('dd-MM-yyyy, HH:mm').format(
                                      DateTime.parse(
                                        jobApplicationStatus['applied_date'],
                                      ),
                                    )
                                    : 'Đang cập nhật...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'Hồ sơ đã gửi tới Nhà tuyển dụng',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Phân tích mức độ cạnh tranh
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.pinkAccent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phân tích mức độ cạnh tranh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '✨ VietnamWorks AI',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio: 3,
                            children: [
                              _buildAnalysisItem(
                                'Xếp hạng của bạn so với ứng viên khác?',
                              ),
                              _buildAnalysisItem(
                                'Bạn phù hợp bao nhiêu cho vị trí này?',
                              ),
                              _buildAnalysisItem(
                                'Mức lương thị trường hiện nay là bao nhiêu?',
                              ),
                              _buildAnalysisItem(
                                'Nhu cầu tuyển dụng vị trí này?',
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Chỉ 29.000đ/lượt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Xem phân tích'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildAnalysisItem(String text) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
