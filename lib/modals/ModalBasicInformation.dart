import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/components/BirthDayPicker.dart';
import 'package:hiredev/components/CustomGenderDropdown/CustomGenderDropdown.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/components/CustomSelectOption/CustomSelectOption.dart';
import 'package:hiredev/models/CityModel.dart';
import 'package:hiredev/models/DistrictModel.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/models/WardModel.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/services/locationServices.dart';
import 'package:hiredev/services/userServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class ModalBasicInformation extends StatefulWidget {
  @override
  State<ModalBasicInformation> createState() => _ModalBasicInformationState();
}

class _ModalBasicInformationState extends State<ModalBasicInformation> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController introductionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final SecureStorageService secureStorageService = SecureStorageService();
  List<CityModel> cities = [];
  late UserModel? userDetail;
  bool isLoading = false;
  int _selectedGender = 0;
  bool isLoadingUpdateUser = false;
  DateTime? _selectedDateOfBirth;
  String _selectedCity = '';
  List<DistrictModel> districts = [];
  String _selectedDistrict = '';
  List<WardModel> wards = [];
  String _selectedWard = '';
  @override
  void initState() {
    super.initState();
    getDetailUser();
    getCity();
  }

  Future<void> getDetailUser() async {
    setState(() {
      isLoading = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserModel? user = userProvider.user;
    final response = await ApiService().get(
      dotenv.get('API_URL') + 'users/${user?.id}',
      token: await secureStorageService.getRefreshToken(),
    );
    if (response['statusCode'] == 200) {
      setState(() {
        userDetail = UserModel.fromJson(response['data']['items']);
        // Initialize controllers with existing values
        nameController.text = userDetail?.fullName ?? '';
        emailController.text = userDetail?.email ?? '';
        phoneController.text = userDetail?.phone ?? '';
        introductionController.text = userDetail?.introduce ?? '';
        addressController.text = userDetail?.address ?? '';

        // If user has location data, load the related districts and wards
        if (userDetail?.cityId != null) {
          _selectedCity = userDetail!.cityId!['_id'].toString();
          getDistrict(_selectedCity);
        }
        if (userDetail?.districtId != null) {
          _selectedDistrict = userDetail!.districtId!['_id'].toString();
          getWard(_selectedDistrict);
        }
        if (userDetail?.wardId != null) {
          _selectedWard = userDetail!.wardId!['_id'].toString();
        }
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getCity() async {
    try {
      final cityList = await LocationServices.getCities();
      setState(() {
        cities = cityList; // Lưu danh sách CityModel trực tiếp
      });
    } catch (e) {
      print('Lỗi khi tải danh sách thành phố: $e');
      // Xử lý lỗi (ví dụ: hiển thị thông báo lỗi cho người dùng)
    }
  }

  Future<void> getDistrict(String cityId) async {
    try {
      final districtList = await LocationServices.getDistricts(cityId);
      print("districtList111: $districtList");
      setState(() {
        districts = districtList;
      });
    } catch (e) {
      print('Error loading districts: $e');
      // Handle the error gracefully
      setState(() {
        districts = []; // Reset to empty list on error
      });
    }
  }

  Future<void> getWard(String districtId) async {
    try {
      final wardList = await LocationServices.getWards(districtId);
      print("wardList111: $wardList");
      setState(() {
        wards = wardList;
      });
    } catch (e) {
      print('Error loading wards: $e');
      setState(() {
        wards = []; // Reset to empty list on error
      });
    }
  }

  void _saveData() async {
    setState(() {
      isLoading = true;
    });
    // Check required fields
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập họ và tên.')));
      return;
    }

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập email.')));
      return;
    }

    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập số điện thoại.')));
      return;
    }

    if (_selectedDateOfBirth == null && userDetail?.birthday == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn ngày sinh.')));
      return;
    }

    if (_selectedCity.isEmpty && userDetail?.cityId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn thành phố.')));
      return;
    }

    if ((_selectedCity.isNotEmpty || userDetail?.cityId != null) &&
        _selectedDistrict.isEmpty &&
        userDetail?.districtId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn quận/huyện.')));
      return;
    }

    if ((_selectedDistrict.isNotEmpty || userDetail?.districtId != null) &&
        _selectedWard.isEmpty &&
        userDetail?.wardId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn phường/xã.')));
      return;
    }

    final cityId =
        _selectedCity.isNotEmpty ? _selectedCity : userDetail?.cityId;
    final districtId =
        _selectedDistrict.isNotEmpty
            ? _selectedDistrict
            : userDetail?.districtId;
    final wardId =
        _selectedWard.isNotEmpty ? _selectedWard : userDetail?.wardId;

    final response = await UserServices.updateUser({
      'full_name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'introduce': introductionController.text,
      'city_id': cityId,
      'district_id': districtId,
      'ward_id': wardId,
      'address': addressController.text,
      'birthday':
          _selectedDateOfBirth?.toIso8601String() ?? userDetail?.birthday,
      'gender': _selectedGender,
      'id': userDetail?.id,
    }, context: context);
    print("response333: ${response['message']}");
    if (response['statusCode'] == 400) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(response['message']),
            ),
      );
    }
    if (response['statusCode'] == 200) {
      Navigator.pop(context);
    }
    setState(() {
      isLoading = false;
    });
    print("response: $response");
  }

  @override
  Widget build(BuildContext context) {
    print("USERDETAILCITY: ${userDetail?.districtId?['_id']}");
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.94,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text(
                    'Thông tin cơ bản',
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  automaticallyImplyLeading: false,
                ),
                CustomInput(
                  label: "Họ & Tên",
                  hint: "${userDetail?.fullName}",
                  controller: nameController,
                  required: true,
                ),
                SizedBox(height: 16),
                CustomInput(
                  label: "Email",
                  hint: "${userDetail?.email}",
                  controller: emailController,
                  required: true,
                  disabled: true,
                ),
                SizedBox(height: 16),
                CustomInput(
                  label: "Số điện thoại",
                  hint: "${userDetail?.phone}",
                  controller: phoneController,
                  required: true,
                ),
                SizedBox(height: 16),
                CustomGenderDropdown(
                  initialValue: userDetail?.gender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                BirthdayPicker(
                  initialDateOfBirth:
                      userDetail?.birthday != null
                          ? DateTime.parse(userDetail?.birthday ?? '')
                          : null,
                  onDateOfBirthChanged: (value) {
                    setState(() {
                      _selectedDateOfBirth = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                CustomInput(
                  label: "Giới thiệu",
                  hint: "${userDetail?.introduce}",
                  controller: introductionController,
                  type: InputType.textarea,
                  required: false,
                ),
                SizedBox(height: 16),
                CustomSelectOption(
                  initialValue: userDetail?.cityId?['_id'],
                  label: "Thành phố",
                  items:
                      cities.isEmpty
                          ? []
                          : cities
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city.id,
                                  child: Text(city.name),
                                ),
                              )
                              .toList(),
                  onChanged: (value) {
                    print("value: $value");
                    setState(() {
                      _selectedCity = value?.toString() ?? '';
                      _selectedDistrict = '';
                      _selectedWard = '';
                      districts = [];
                      wards = [];
                    });
                    if (value != null) {
                      getDistrict(value.toString());
                    }
                  },
                ),
                SizedBox(height: 16),
                if (districts.isNotEmpty ||
                    userDetail?.districtId?['_id'] != null)
                  CustomSelectOption(
                    initialValue: userDetail?.districtId?['_id'],
                    label: "Quận/Huyện",
                    items:
                        districts
                            .map(
                              (district) => DropdownMenuItem<String>(
                                value: district.id,
                                child: Text(district.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value?.toString() ?? '';
                        _selectedWard = '';
                        wards = [];
                      });
                      if (value != null) {
                        getWard(value.toString());
                      }
                    },
                  ),
                SizedBox(height: 16),
                if (wards.isNotEmpty || userDetail?.wardId?['_id'] != null)
                  CustomSelectOption(
                    initialValue: userDetail?.wardId?['_id'],
                    label: "Phường/Xã",
                    items:
                        wards
                            .map(
                              (ward) => DropdownMenuItem<String>(
                                value: ward.id,
                                child: Text(ward.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWard = value?.toString() ?? '';
                      });
                    },
                  ),
                SizedBox(height: 16),
                if (_selectedWard.isNotEmpty || userDetail?.wardId != null)
                  CustomInput(
                    label: "Địa chỉ",
                    hint: "${userDetail?.address}",
                    controller: addressController,
                    type: InputType.textarea,
                    required: true,
                  ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveData, // Gọi hàm _saveData khi nhấn nút
                    child: Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
  }
}
