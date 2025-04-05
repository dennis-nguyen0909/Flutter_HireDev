import 'package:flutter/material.dart';
import 'package:hiredev/screens/ScreenListCompany/ScreenListCompany.dart';
import 'package:hiredev/services/CompanyServices.dart';

class Companies extends StatefulWidget {
  @override
  _CompaniesState createState() => _CompaniesState();
}

class _CompaniesState extends State<Companies> {
  String idRoleEmployer = '';
  List<dynamic> companies = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getRoleEmployer();
  }

  Future<void> getCompanies(String idRoleEmployer) async {
    if (idRoleEmployer.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await CompanyServices.getCompanies(
        '',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Công ty nổi bật',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                companies.map((company) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CompanyCard(company: company),
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Xử lý khi nhấn Xem tất cả
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScreenListCompany()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.0),
            ),
            child: Text(
              'Xem tất cả',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class CompanyCard extends StatelessWidget {
  final dynamic company;

  CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    print("COMPANY: $company");
    return Container(
      width: 120, // Điều chỉnh chiều rộng theo ý muốn
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
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              company['avatar_company'] ?? 'https://via.placeholder.com/60',
              height: 60, // Điều chỉnh chiều cao logo theo ý muốn
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.business, size: 60);
              },
            ),
          ),
          Text(
            company['company_name'] ?? 'Unknown',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Xử lý khi nhấn Việc mới
            },
            child: Text('Việc mới'),
          ),
        ],
      ),
    );
  }
}
