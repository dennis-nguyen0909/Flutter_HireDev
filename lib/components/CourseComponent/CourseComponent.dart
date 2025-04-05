import 'package:flutter/material.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/CourseModal.dart';
import 'package:hiredev/modals/EducationModal.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/CourseServices.dart';
import 'package:hiredev/services/EducationServices.dart';
import 'package:provider/provider.dart';

class CourseComponent extends StatefulWidget {
  @override
  _CourseComponentState createState() => _CourseComponentState();
}

class _CourseComponentState extends State<CourseComponent> {
  List<dynamic> courses = [];
  @override
  void initState() {
    super.initState();
    getCourseOfCandidate(1, 10);
  }

  Future<void> getCourseOfCandidate(int current, int pageSize) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final response = await CourseServices.getCourseByUserToken(
      user!.id!,
      current,
      pageSize,
    );
    print("getCourseOfCandidate: $response");
    if (response['statusCode'] == 200) {
      setState(() {
        courses = response['data']['items'];
      });
    }
  }

  Future<void> onUpdateCourse(dynamic course) async {
    final response = await CourseServices.updateCourse(course['_id'], course);

    if (response['statusCode'] == 200) {
      getCourseOfCandidate(1, 10);
      Navigator.pop(context);
    }
  }

  Future<void> createCourse(dynamic course) async {
    final response = await CourseServices.createCourse(course);
    print("createCourse1: $response");
    if (response['statusCode'] == 201) {
      getCourseOfCandidate(1, 10);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionComponent(
      title: 'Khóa học',
      description: 'Thể hiện những khóa học bạn đã tham gia.',
      items: courses,
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
                                child: CourseModal(
                                  course: item,
                                  onUpdate: onUpdateCourse,
                                  onCreate: createCourse,
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
                                        await CourseServices.deleteCourse(
                                          item['_id'],
                                        );
                                        getCourseOfCandidate(
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
                        item['course_name'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
                Text(
                  item['organization_name'] ?? '',
                  style: TextStyle(fontSize: 14.0),
                ),
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
        child: CourseModal(onCreate: createCourse),
      ),
    );
  }
}
