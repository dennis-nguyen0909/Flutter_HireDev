import 'package:flutter/material.dart';
import 'package:hiredev/screens/ScreenListCompany/ScreenListCompany.dart';
import 'package:hiredev/services/CompanyServices.dart';
import 'package:rxdart/rxdart.dart'; // Import thư viện rxdart

class Companies extends StatefulWidget {
  @override
  _CompaniesState createState() => _CompaniesState();
}

class _CompaniesState extends State<Companies> {
  String idRoleEmployer = '';
  List<dynamic> companies = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>.seeded(
    '',
  );

  @override
  void initState() {
    super.initState();
    getRoleEmployer();
    _searchSubject
        .debounceTime(Duration(milliseconds: 300)) // Debounce 300ms
        .listen((searchQuery) {
          if (idRoleEmployer.isNotEmpty) {
            _getCompanies(idRoleEmployer, searchQuery);
          }
        });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  Future<void> _getCompanies(String idRoleEmployer, String searchQuery) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await CompanyServices.getCompanies(
        searchQuery,
        idRoleEmployer,
        1,
        10,
      );
      print("EMPLOYER SEARCH '$searchQuery': $response");

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

      // Load initial companies without a search query
      if (idRoleEmployer.isNotEmpty) {
        _getCompanies(idRoleEmployer, '');
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
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm công ty...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          onChanged: (value) {
            _searchSubject.add(
              value,
            ); // Thêm giá trị vào Subject khi có thay đổi
          },
        ),
        SizedBox(height: 16),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
      width: 120,
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.network(
                company['avatar_company'] ?? 'https://via.placeholder.com/60',
                height: 60,
                width: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Icon(
                      Icons.business,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
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
