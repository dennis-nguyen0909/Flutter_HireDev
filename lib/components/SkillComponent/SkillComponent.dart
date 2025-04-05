import 'package:flutter/material.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/EducationModal.dart';
import 'package:hiredev/modals/SkillModal.dart';
import 'package:hiredev/services/EducationServices.dart';
import 'package:hiredev/services/SkillServices.dart';

class SkillComponent extends StatefulWidget {
  @override
  _SkillComponentState createState() => _SkillComponentState();
}

class _SkillComponentState extends State<SkillComponent> {
  List<dynamic> skills = [];
  @override
  void initState() {
    super.initState();
    getSkillsOfCandidate();
  }

  Future<void> getSkillsOfCandidate() async {
    final response = await SkillServices.getSkillByUserToken();
    print("getSkillsOfCandidate: $response");
    if (response['statusCode'] == 200) {
      setState(() {
        skills = response['data'];
      });
    }
  }

  Future<void> onUpdateSkill(dynamic skill) async {
    final response = await SkillServices.updateSkill(skill['_id'], skill);

    if (response['statusCode'] == 200) {
      getSkillsOfCandidate();
      Navigator.pop(context);
    }
  }

  Future<void> createSkill(dynamic skill) async {
    final response = await SkillServices.createSkill(skill);
    print("createSkill: $response");
    if (response['statusCode'] == 201) {
      getSkillsOfCandidate();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionComponent(
      title: 'Kỹ năng',
      description:
          'Thể hiện những kiến thức kỹ năng bạn có cho công việc của mình.',
      items: skills,
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
                                child: SkillModal(
                                  skill: item,
                                  onUpdate: onUpdateSkill,
                                  onCreate: createSkill,
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
                                        await SkillServices.deleteSkill(
                                          item['_id'],
                                        );
                                        getSkillsOfCandidate(); // Refresh the list
                                      } catch (e) {
                                        print("Error deleting skill: $e");
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
                        item['name'] ?? '',
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
                  item['description'] ?? '',
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 4.0),
                Text(
                  '${item['evalute'] ?? ''}',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        );
      },
      modalContent: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        child: SkillModal(onCreate: createSkill),
      ),
    );
  }
}
