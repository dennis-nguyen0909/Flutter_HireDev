import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/models/Location.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  SecureStorageService secureStorageService = SecureStorageService();
  List<LocationModel> locations = [];
  LocationModel? selectedLocation;
  TextEditingController searchController = TextEditingController();
  int selectedCount = 0;
  String selectedLocationName = '';
  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! + 'cities?depth=1',
      token: await secureStorageService.getRefreshToken(),
    );
    if (response['statusCode'] == 200) {
      setState(() {
        locations =
            (response['data'] as List)
                .map((item) => LocationModel.fromJson(item))
                .toList();
      });
    }
  }

  void updateSelectedCount() {
    setState(() {
      selectedCount = selectedLocation != null ? 1 : 0;
      selectedLocationName = selectedLocation?.name ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFcccccc),
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
          'Địa điểm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Color(0xFFcccccc),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: ListView.separated(
                itemCount: locations.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final isSelected =
                      selectedLocation?.id == locations[index].id;
                  return ListTile(
                    title: Text(
                      locations[index].name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedLocation = locations[index];
                        updateSelectedCount();
                      });
                    },
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: Colors.orange,
                              size: 20,
                            )
                            : null,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    tileColor:
                        isSelected ? Colors.orange.withOpacity(0.1) : null,
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Text(
                        "Địa điểm đã chọn:",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 29, 20, 20),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        selectedLocationName,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ButtonCustom(
                        text: "Áp dụng",
                        onPressed: () {
                          // Return the selected location to the previous screen
                          Navigator.pop(context, {
                            'id': selectedLocation?.id,
                            'name': selectedLocation?.name,
                            'location': selectedLocation,
                          });
                        },
                        size: ButtonSize.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
