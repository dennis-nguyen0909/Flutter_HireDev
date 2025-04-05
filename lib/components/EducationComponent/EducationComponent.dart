import 'package:flutter/material.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/EducationModal.dart';
import 'package:hiredev/services/EducationServices.dart';

class EducationComponent extends StatefulWidget {
  @override
  _EducationComponentState createState() => _EducationComponentState();
}

class _EducationComponentState extends State<EducationComponent> {
  List<dynamic> educations = [];
  @override
  void initState() {
    super.initState();
    getEducationOfCandidate();
  }

  Future<void> getEducationOfCandidate() async {
    final response = await EducationServices.getEducationByUserToken();
    print("getEducationOfCandidate: $response");
    if (response['statusCode'] == 200) {
      setState(() {
        educations = response['data'];
      });
    }
  }

  Future<void> onUpdateEducation(dynamic education) async {
    final response = await EducationServices.updateEducation(
      education['_id'],
      education,
    );
    if (response['statusCode'] == 200) {
      getEducationOfCandidate();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionComponent(
      title: 'Học vấn',
      description:
          'Thể hiện những kiến thức học vấn bạn có cho công việc của mình.',
      items: educations,
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
                                child: EducationModal(
                                  education: item,
                                  onUpdate: onUpdateEducation,
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
                                        await EducationServices.deleteEducation(
                                          item['_id'],
                                        );
                                        getEducationOfCandidate(); // Refresh the list
                                      } catch (e) {
                                        print("Error deleting education: $e");
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
                        item['school'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
                Text(item['major'] ?? '', style: TextStyle(fontSize: 14.0)),
                SizedBox(height: 4.0),
                Text(
                  '${DateTime.parse(item['start_date']).year} - ${item['end_date'] != null ? DateTime.parse(item['end_date']).year : 'Hiện tại'}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
      modalContent: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        child: EducationModal(),
      ),
    );
  }
}
