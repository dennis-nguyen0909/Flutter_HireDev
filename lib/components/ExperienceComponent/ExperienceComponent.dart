import 'package:flutter/material.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/CourseModal.dart';
import 'package:hiredev/modals/EducationModal.dart';
import 'package:hiredev/modals/ExperienceModal.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/CourseServices.dart';
import 'package:hiredev/services/EducationServices.dart';
import 'package:hiredev/services/ExperienceServices.dart';
import 'package:provider/provider.dart';

class ExperienceComponent extends StatefulWidget {
  @override
  _ExperienceComponentState createState() => _ExperienceComponentState();
}

class _ExperienceComponentState extends State<ExperienceComponent> {
  List<dynamic> experiences = [];
  @override
  void initState() {
    super.initState();
    getExperienceOfCandidate(1, 10);
  }

  Future<void> getExperienceOfCandidate(int current, int pageSize) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final response = await ExperienceServices.getExperienceByUserToken(
      user!.id!,
      current,
      pageSize,
    );
    print("duydeptraivcl: $response");

    if (response['statusCode'] == 200) {
      setState(() {
        experiences = response['data'];
      });
    }
  }

  Future<void> onUpdateExperience(dynamic experience) async {
    final response = await ExperienceServices.updateExperience(
      experience['_id'],
      experience,
    );

    if (response['statusCode'] == 200) {
      getExperienceOfCandidate(1, 10);
      Navigator.pop(context);
    }
  }

  Future<void> createExperience(dynamic experience) async {
    final response = await ExperienceServices.createExperience(experience);
    print("createExperience1: $response");
    if (response['statusCode'] == 201) {
      getExperienceOfCandidate(1, 10);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("experiences: $experiences");
    return SectionComponent(
      title: 'Kinh nghiệm làm việc',
      description: 'Thể hiện những kinh nghiệm làm việc bạn đã có.',
      items: experiences,
      renderItem: (item) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit, color: Colors.blue),
                        title: Text('Chỉnh sửa'),
                        onTap: () {
                          Navigator.pop(context);
                          // Show edit modal with pre-filled data
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.94,
                                child: ExperienceModal(
                                  experience: item,
                                  onUpdate: onUpdateExperience,
                                  onCreate: createExperience,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Xóa'),
                        onTap: () {
                          Navigator.pop(context);
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Xác nhận xóa'),
                                content: Text(
                                  'Bạn có chắc chắn muốn xóa thông tin học vấn này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      // Delete education
                                      try {
                                        await ExperienceServices.deleteExperience(
                                          item['_id'],
                                        );
                                        getExperienceOfCandidate(
                                          1,
                                          10,
                                        ); // Refresh the list
                                      } catch (e) {
                                        print("Error deleting course: $e");
                                      }
                                    },
                                    child: Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
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
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['company'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
                Text(item['position'] ?? '', style: TextStyle(fontSize: 14.0)),
                SizedBox(height: 4.0),
                Text(
                  '${DateTime.parse(item['start_date']).month}/${DateTime.parse(item['start_date']).year} - ${item['end_date'] != null ? "${DateTime.parse(item['end_date']).month}/${DateTime.parse(item['end_date']).year}" : 'Hiện tại'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
      modalContent: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        child: ExperienceModal(onCreate: createExperience),
      ),
    );
  }
}
