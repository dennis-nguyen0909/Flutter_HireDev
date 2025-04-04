import 'package:flutter/material.dart';
import 'package:hiredev/modals/ModalBasicInformation.dart';
import 'package:hiredev/models/UserMode.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    user = userProvider.user;
    getJobAppliedOfCandidate();
    getJobSavedOfCandidate();
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        user?.avatar ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 16),
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
                      '${user?.totalExperienceYears} năm kinh nghiệm',
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
                child: Text(
                  'Hồ sơ ứng tuyển',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
