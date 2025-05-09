import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hiredev/screens/InfoCompany/InfoCompany.dart';
import 'package:hiredev/screens/JobApplicationStatusScreen/JobApplicationStatusScreen.dart';
import 'package:hiredev/screens/jobDetail/JobDetail.dart';
import 'package:hiredev/utils/currency.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class JobCard extends StatelessWidget {
  final Map<dynamic, dynamic> appliedJob;
  final bool isApplied;
  JobCard(this.appliedJob, this.isApplied);

  @override
  Widget build(BuildContext context) {
    print("appliedJob: ${appliedJob}");

    // Check if job_id exists, if not return empty container
    if (appliedJob['job_id'] == null) {
      return Container();
    }

    return GestureDetector(
      onTap: () => _showJobOptions(context), // Khi click vào JobCard
      child: Card(
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
                    appliedJob['employer_id']?['avatar_company'] ??
                        appliedJob['job_id']?['user_id']?['avatar_company'] ??
                        'https://via.placeholder.com/50', // Ảnh mặc định
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 10),
                  Text(
                    appliedJob['job_id']['company_name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                appliedJob['job_id']['title'] ?? '',
                style: TextStyle(fontSize: 14),
              ),
              appliedJob['job_id']['is_negotiable'] == 'true'
                  ? Text('Thỏa thuận', style: TextStyle(fontSize: 14))
                  : Text(
                    Currency.formatCurrencyWithSymbol(
                          int.tryParse(
                                appliedJob['job_id']['salary_range_min']
                                        ?.toString() ??
                                    '',
                              ) ??
                              0,
                          appliedJob['job_id']['type_money']['symbol'] ?? '',
                        ) +
                        " - " +
                        Currency.formatCurrencyWithSymbol(
                          int.tryParse(
                                appliedJob['job_id']['salary_range_max']
                                        ?.toString() ??
                                    '',
                              ) ??
                              0,
                          appliedJob['job_id']['type_money']['symbol'] ?? '',
                        ),
                    style: TextStyle(fontSize: 14),
                  ),
              Text(
                appliedJob['job_id']['city_id']['name'] ?? '',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    (appliedJob['job_id']['skill_name'] != null)
                        ? appliedJob['job_id']['skill_name'].map<Widget>((
                          skill,
                        ) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFD1D5DB)),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList()
                        : [],
              ),
              SizedBox(height: 6),
              isApplied
                  ? Text(
                    'Hồ sơ đã gửi tới Nhà tuyển dụng',
                    style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                  )
                  : Text(
                    'Hồ sơ đã lưu',
                    style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 Hiển thị modal khi click vào JobCard
  void _showJobOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.check_circle),
                title: Text('Xem trạng thái ứng tuyển'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => JobApplicationStatusScreen(
                            appliedJob: appliedJob,
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Xem hồ sơ ứng tuyển'),
                onTap: () {
                  print("appliedJob: ${appliedJob['cv_id']}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Scaffold(
                            appBar: AppBar(
                              title: Text(
                                'Xem chi tiết',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
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
                              leading: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            body:
                                appliedJob['cv_id'] == null
                                    ? Center(
                                      child: Text(
                                        'CV không tồn tại hoặc đã bị xóa',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                    : PDF().fromUrl(
                                      appliedJob['cv_id']['cv_link'],
                                      placeholder:
                                          (progress) => Center(
                                            child: Text('$progress %'),
                                          ),
                                      errorWidget:
                                          (error) => Center(
                                            child: Text(error.toString()),
                                          ),
                                    ),
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.work),
                title: Text('Xem chi tiết công việc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => JobDetailScreen(
                            id: appliedJob['job_id']['_id'],
                            title: appliedJob['job_id']['title'],
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.business),
                title: Text('Xem thông tin công ty'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => InfoCompanyScreen(
                            userId: appliedJob['employer_id']['_id'],
                          ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Đóng'),
                onTap: () => Navigator.pop(context), // Đóng modal
              ),
            ],
          ),
        );
      },
    );
  }
}
