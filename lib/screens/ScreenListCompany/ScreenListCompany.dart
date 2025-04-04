import 'package:flutter/material.dart';
import 'package:hiredev/screens/InfoCompany/InfoCompany.dart';
import 'package:hiredev/services/CompanyServices.dart';
import 'dart:async';

class ScreenListCompany extends StatefulWidget {
  @override
  _ScreenListCompanyState createState() => _ScreenListCompanyState();
}

class _ScreenListCompanyState extends State<ScreenListCompany> {
  String idRoleEmployer = '';
  List<dynamic> companies = [];
  bool isLoading = false;
  String companyName = '';
  Timer? _debounce;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getRoleEmployer();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    print("companyName: $companyName");
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        companyName = _searchController.text;
      });
      if (idRoleEmployer.isNotEmpty) {
        getCompanies(idRoleEmployer);
      }
    });
  }

  Future<void> getCompanies(String idRoleEmployer) async {
    if (idRoleEmployer.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await CompanyServices.getCompanies(
        companyName,
        idRoleEmployer,
        1,
        10,
      );
      print("EMPLOYER: $response");

      if (response['statusCode'] == 200) {
        setState(() {
          companies = response['data']['items'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching companies: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getRoleEmployer() async {
    final response = await CompanyServices.getRoleEmployer();
    if (response['statusCode'] == 200) {
      setState(() {
        idRoleEmployer = response['data']['_id'];
      });

      // Only call getCompanies if we have a valid idRoleEmployer
      if (idRoleEmployer.isNotEmpty) {
        getCompanies(idRoleEmployer);
      }
    }
    print("idRoleEmployer: $idRoleEmployer");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDA4156), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(
          'Công ty',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khám Phá Văn Hoá Công Ty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên công ty',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Công Ty Nổi Bật',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              companies.isEmpty
                                  ? [
                                    Center(child: Text('Không có công ty nào')),
                                  ]
                                  : companies.map((company) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: CompanyCard(
                                        idCompany: company['_id'],
                                        imageUrl:
                                            company['avatar_company'] ??
                                            'https://via.placeholder.com/80',
                                        companyName:
                                            company['company_name'] ??
                                            'Unknown',
                                        details:
                                            company['industry'] ??
                                            'Không có thông tin',
                                        followers:
                                            '${company['followers_count'] ?? 0} lượt theo dõi',
                                        jobs:
                                            '${company['jobs_count'] ?? 0} việc làm',
                                      ),
                                    );
                                  }).toList(),
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final String idCompany;
  final String imageUrl;
  final String companyName;
  final String details;
  final String followers;
  final String jobs;

  CompanyCard({
    required this.idCompany,
    required this.imageUrl,
    required this.companyName,
    required this.details,
    required this.followers,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoCompanyScreen(userId: idCompany),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child:
                  imageUrl.startsWith('http')
                      ? Image.network(
                        imageUrl,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Icon(Icons.business, size: 40),
                          );
                        },
                      )
                      : Image.asset(
                        imageUrl,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    details,
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(followers, style: TextStyle(fontSize: 12)),
                  Text(jobs, style: TextStyle(fontSize: 12)),
                  // SizedBox(height: 8),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   child: Text('Theo dõi'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.blue,
                  //     foregroundColor: Colors.white,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyCardLarge extends StatelessWidget {
  final String imageUrl;
  final String companyName;
  final String details;
  final String followers;
  final String jobs;

  CompanyCardLarge({
    required this.imageUrl,
    required this.companyName,
    required this.details,
    required this.followers,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child:
                    imageUrl.startsWith('http')
                        ? Image.network(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: Icon(Icons.business, size: 60),
                            );
                          },
                        )
                        : Image.asset(
                          imageUrl,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EST',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('1976', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child:
                        imageUrl.startsWith('http')
                            ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.business);
                              },
                            )
                            : Image.asset(
                              'assets/vinamilk_logo.png',
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  details,
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(followers, style: TextStyle(fontSize: 12)),
                Text(jobs, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
