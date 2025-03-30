import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/AlertDiaLog/CustomAlertDiaLog.dart';
import 'package:hiredev/components/CV/CV.dart';
import 'package:hiredev/components/JobCard/CardApply.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class ResumeItem {
  final String id;
  final String userId;
  final String cvName;
  final String cvLink;
  final String publicId;
  final int bytes;
  final String createdAt;
  final String updatedAt;
  final int v;

  ResumeItem({
    required this.id,
    required this.userId,
    required this.cvName,
    required this.cvLink,
    required this.publicId,
    required this.bytes,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ResumeItem.fromJson(Map<String, dynamic> json) {
    return ResumeItem(
      id: json['_id'],
      userId: json['user_id'],
      cvName: json['cv_name'],
      cvLink: json['cv_link'],
      publicId: json['public_id'],
      bytes: json['bytes'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class ResumeResponse {
  final List<ResumeItem> items;
  final Map<String, dynamic> meta;

  ResumeResponse({required this.items, required this.meta});

  factory ResumeResponse.fromJson(Map<String, dynamic> json) {
    return ResumeResponse(
      items:
          (json['items'] as List)
              .map((item) => ResumeItem.fromJson(item))
              .toList(),
      meta: json['meta'],
    );
  }
}

class ApplyJob extends StatefulWidget {
  const ApplyJob({
    super.key,
    required this.jobTitle,
    required this.jobImage,
    required this.companyName,
    required this.isNegotiable,
    required this.city,
    required this.district,
    required this.salaryType,
    required this.typeMoney,
    required this.salaryRangeMax,
    required this.salaryRangeMin,
    required this.jobId,
    required this.employerId,
  });

  final String jobTitle;
  final String jobImage;
  final String companyName;
  final String isNegotiable;
  final String city;
  final String district;
  final String salaryType;
  final String typeMoney;
  final num salaryRangeMax;
  final num salaryRangeMin;
  final String jobId;
  final String employerId;

  @override
  State<ApplyJob> createState() => _ApplyJobState();
}

class _ApplyJobState extends State<ApplyJob> {
  List<ResumeItem> resumes = [];
  SecureStorageService secureStorageService = SecureStorageService();
  int currentPage = 1;
  String? selectedResumeId; // Store the ID of the selected resume

  @override
  void initState() {
    super.initState();
    getAllCV(currentPage, 10, {});
  }

  void onResumeSelected(String id) {
    setState(() {
      if (selectedResumeId == id) {
        selectedResumeId = null; // Deselect if already selected
      } else {
        selectedResumeId = id; // Select the new ID
      }
    });
  }

  Future<void> applyJob() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    if (selectedResumeId != null) {
      print('Ứng tuyển với resume ID: $selectedResumeId');
      final params = {
        'job_id': widget.jobId,
        'cv_id': selectedResumeId,
        'cover_letter': '',
        'employer_id': widget.employerId,
        'user_id': user?.id,
      };
      print("params: $params");
      final response = await ApiService().post(
        dotenv.env['API_URL']! + 'applications',
        params,
        token: await secureStorageService.getRefreshToken(),
      );
      if (response['statusCode'] == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: 'Thông báo',
              content: 'Ứng tuyển thành công.',
              buttonText: 'OK',
              onPressed: () {
                Navigator.of(context).pop();
              },
              logoAssetPath: 'assets/LogoH.png',
            );
          },
        );
        Navigator.pop(context);
        return;
      }
      if (response['response']['statusCode'] == 400) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: 'Thông báo',
              content: response['response']['message'],
              buttonText: 'OK',
              onPressed: () {
                Navigator.of(context).pop();
              },
              logoAssetPath: 'assets/LogoH.png',
            );
          },
        );
        return;
      }
      print('responseduy: ${response['response']['statusCode']}');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: 'Thông báo',
            content: 'Vui lòng chọn một CV để ứng tuyển.',
            buttonText: 'OK',
            onPressed: () {
              Navigator.of(context).pop();
            },
            logoAssetPath: 'assets/LogoH.png',
          );
        },
      );
    }
  }

  Future<void> getAllCV(current, pageSize, query) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    final response = await ApiService().get(
      dotenv.env['API_URL']! +
          'cvs?current=$current&pageSize=$pageSize&query[user_id]=${user?.id}',
      token: await secureStorageService.getRefreshToken(),
    );

    if (response['statusCode'] == 200) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final resumeResponse = ResumeResponse.fromJson(data);
        setState(() {
          resumes.addAll(resumeResponse.items);
          currentPage = resumeResponse.meta['current_page'];
          if (currentPage < resumeResponse.meta['total_pages']) {
            getAllCV(currentPage + 1, pageSize, query);
          }
        });
      } else {
        print("Error: response['data'] is not a Map<String, dynamic>");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFDA4156), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Container(
                margin: EdgeInsets.only(top: 50),
                child: Center(
                  child: Text(
                    'Ứng tuyển công việc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 80, // Adjust bottom to leave space for the button
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... your CardApply and CV list code
                    CardApply(
                      jobImage: widget.jobImage,
                      companyName: widget.companyName,
                      jobTitle: widget.jobTitle,
                      isNegotiable: widget.isNegotiable == "true",
                      city: widget.city,
                      district: widget.district,
                      salaryRangeMin: widget.salaryRangeMin,
                      salaryRangeMax: widget.salaryRangeMax,
                      typeMoney: widget.typeMoney,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Hồ sơ ứng tuyển',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: resumes.length,
                      itemBuilder: (context, index) {
                        final resume = resumes[index];
                        final isSelected = selectedResumeId == resume.id;
                        return Card(
                          color: Colors.white,
                          elevation: 3,
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: CV(
                              name: resume.cvName,
                              link: resume.cvLink,
                              id: resume.id,
                              onSelected: onResumeSelected,
                              isSelected: isSelected,
                            ),
                          ),
                        );
                      },
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
              width: double.infinity,

              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     colors: [Color(0xFFDA4156), Colors.black],
              //     begin: Alignment.topLeft,
              //     end: Alignment.bottomCenter,
              //   ),
              // ),
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                onPressed: applyJob,
                child: Text(
                  'Ứng tuyển',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
