import 'package:flutter/material.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/JobCard/CardApply.dart';
import 'package:hiredev/utils/currency.dart';

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

  @override
  State<ApplyJob> createState() => _ApplyJobState();
}

class _ApplyJobState extends State<ApplyJob> {
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
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
                    Card(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Text(
                            'Hồ sơ ứng tuyển',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
