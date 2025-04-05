import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hiredev/components/CertificateComponent/CertificateComponent.dart';
import 'package:hiredev/components/CourseComponent/CourseComponent.dart';
import 'package:hiredev/components/EducationComponent/EducationComponent.dart';
import 'package:hiredev/components/ExperienceComponent/ExperienceComponent.dart';
import 'package:hiredev/components/PrizeComponent/PrizeComponent.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/EducationModal.dart';
import 'package:hiredev/modals/ModalBasicInformation.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/EducationServices.dart';
import 'package:hiredev/services/fileService.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:hiredev/services/userServices.dart';
import 'package:hiredev/utils/CameraSystem.dart';
import 'package:hiredev/utils/ImagePicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:hiredev/modals/PrizeModal.dart';
import 'package:hiredev/modals/CourseModal.dart';
import 'package:hiredev/modals/ProjectModal.dart';
import 'package:hiredev/modals/ExperienceModal.dart';
import 'package:hiredev/modals/CertificateModal.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProvider userProvider;
  late UserModel? user;
  int jobApplied = 0;
  int jobSaved = 0;
  bool isLoadingApplied = true;
  bool isLoadingSaved = true;
  String? _selectedImagePath;
  List<dynamic> educations = [];
  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    user = userProvider.user;
    getJobAppliedOfCandidate();
    getJobSavedOfCandidate();
  }

  Future<void> _pickImageFromCamera() async {
    final imageFile = await ImagePickerService().pickImageFromCamera();
    if (imageFile != null) {
      // Xử lý ảnh đã chọn
      print('Ảnh đã chọn từ camera: ${imageFile.path}');
    } else {
      print('Không có ảnh nào được chọn từ camera.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final imageFile = await ImagePickerService().pickImageFromGallery();
    if (imageFile != null) {
      // Xử lý ảnh đã chọn
      print('Ảnh đã chọn từ thư viện: ${imageFile.path}');
      final uploadFile = await FileService.uploadFile(imageFile.path);
      final jsonResponse = jsonDecode(uploadFile ?? '');
      if (jsonResponse['statusCode'] == 201) {
        setState(() {
          _selectedImagePath = imageFile.path;
        });
        print('uploadFile: $jsonResponse');
        final updateUser = await UserServices.updateUser({
          "id": user?.id,
          "avatar": jsonResponse['data']['url'],
        }, context: context);
        print('updateUser: $updateUser');
      } else {
        print('uploadFile: $jsonResponse');
      }
    } else {
      print('Không có ảnh nào được chọn từ thư viện.');
    }
  }

  Future<void> getJobAppliedOfCandidate() async {
    try {
      setState(() {
        isLoadingApplied = true;
      });
      final response = await ProfileServices.getJobAppliedOfCandidate(
        user?.id ?? '',
      );
      if (response['statusCode'] == 200) {
        setState(() {
          jobApplied = response['data'];
        });
      } else {
        setState(() {
          jobApplied = 0;
        });
      }
    } catch (e) {
      print("getJobAppliedOfCandidate: $e");
    } finally {
      setState(() {
        isLoadingApplied = false;
      });
    }
  }

  Future<void> getJobSavedOfCandidate() async {
    try {
      setState(() {
        isLoadingSaved = true;
      });
      final response = await ProfileServices.getJobSavedOfCandidate(
        user?.id ?? '',
        1,
        10,
      );
      print("getJobSavedOfCandidate: $response");
      setState(() {
        jobSaved = response;
      });
    } catch (e) {
      print("getJobSavedOfCandidate: $e");
    } finally {
      setState(() {
        isLoadingSaved = false;
      });
    }
  }

  void _showBasicInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ModalBasicInformation(); // Sử dụng widget ModalBasicInfo
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    return Scaffold(
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
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Hồ Sơ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child:
                              _selectedImagePath != null
                                  ? Image.file(
                                    File(_selectedImagePath!),
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                  : user?.avatar != null
                                  ? Image.network(
                                    user?.avatar ?? '',
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/avatar_default.jpg',
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.camera_alt),
                                          title: Text('Chụp ảnh từ camera'),
                                          onTap: () {
                                            _pickImageFromCamera();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.photo_library),
                                          title: Text('Chọn ảnh từ thư viện'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _pickImageFromGallery();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.close),
                                          title: Text('Đóng'),
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFFDA4156),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('0', style: TextStyle(fontSize: 20)),
                          Text(
                            'Lượt xem',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'hồ sơ',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoadingSaved
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey,
                                  ),
                                ),
                              )
                              : Text(
                                '$jobSaved',
                                style: TextStyle(fontSize: 20),
                              ),
                          Text(
                            'Việc làm',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'đã lưu',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isLoadingApplied
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey,
                                  ),
                                ),
                              )
                              : Text(
                                '$jobApplied',
                                style: TextStyle(fontSize: 20),
                              ),
                          Text(
                            'Việc làm',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'ứng tuyển',
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? '', style: TextStyle(fontSize: 18)),
                    // Text(
                    //   user?.email ?? '',
                    //   style: TextStyle(fontSize: 16, color: Colors.grey),
                    // ),
                    Text(
                      '${user?.totalExperienceYears != null ? user?.totalExperienceYears : 0} năm kinh nghiệm',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Thực tập sinh/Sinh viên',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category, color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Khác',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!, width: 1.0),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showBasicInfoModal(context);
                          },
                          icon: Icon(Icons.edit, size: 16, color: Colors.black),
                          label: Text(
                            'Chỉnh sửa thông tin cơ bản',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0, // Độ rộng của border
                              style:
                                  BorderStyle.none, // Ban đầu không có border
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                // Thêm border chỉ ở cạnh trên
                                color: Colors.grey[300]!,
                                width: 1.0,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                color: Colors.blue[50],
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiết kiệm thời gian bằng cách nhập hồ sơ LinkedIn hiện có của bạn!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // ElevatedButton.icon(
                    //   onPressed: () {},
                    //   icon: Image.asset(
                    //     'assets/linkedin_icon.png',
                    //     height: 20,
                    //   ), // Thay thế bằng đường dẫn icon LinkedIn của bạn
                    //   label: Text('Nhập hồ sơ'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     foregroundColor: Colors.white,
                    //   ),
                    // ),
                    SizedBox(height: 8),
                    Text(
                      'Thông tin hồ sơ VietnamWorks sẽ được thay thế bằng thông tin từ tài khoản Linkedin của bạn. Ví dụ: kỹ năng, học vấn, kinh nghiệm,... và bạn không thể hoàn tác.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thiết lập hồ sơ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Bật cho phép tìm kiếm hồ sơ'),
                        Switch(
                          value:
                              false, // Thay đổi giá trị tùy thuộc vào trạng thái
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                    Text(
                      'Bật và cho phép nhà tuyển dụng xem hồ sơ của bạn',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: EducationComponent(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PrizeComponent(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CourseComponent(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PrizeComponent(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ExperienceComponent(),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CertificateComponent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
