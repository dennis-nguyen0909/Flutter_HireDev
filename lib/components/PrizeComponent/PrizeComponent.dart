import 'package:flutter/material.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/PrizeModal.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/PrizeServices.dart';
import 'package:provider/provider.dart';

class PrizeComponent extends StatefulWidget {
  @override
  _PrizeComponentState createState() => _PrizeComponentState();
}

class _PrizeComponentState extends State<PrizeComponent> {
  List<dynamic> prizes = [];
  @override
  void initState() {
    super.initState();
    getPrizeOfCandidate(current: 1, pageSize: 10);
  }

  Future<void> getPrizeOfCandidate({int current = 1, int pageSize = 10}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final response = await PrizeServices.getPrizeByUserToken(
      current: current,
      pageSize: pageSize,
      userId: user?.id,
    );
    print("getPrizeOfCandidate: $response");
    if (response['statusCode'] == 200) {
      setState(() {
        prizes = response['data']['items'];
      });
    }
  }

  Future<void> onUpdatePrize(dynamic prize) async {
    final response = await PrizeServices.updatePrize(prize['_id'], prize);
    if (response['statusCode'] == 200) {
      getPrizeOfCandidate();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionComponent(
      title: 'Giải thưởng',
      description:
          'Thể hiện những giải thưởng bạn đã nhận được cho công việc của mình.',
      items: prizes,
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.94,
                                child: PrizeModal(
                                  prize: item,
                                  onUpdate: onUpdatePrize,
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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Xác nhận xóa'),
                                content: Text(
                                  'Bạn có chắc chắn muốn xóa giải thưởng này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      try {
                                        await PrizeServices.deletePrize(
                                          item['_id'],
                                        );
                                        getPrizeOfCandidate();
                                      } catch (e) {
                                        print("Error deleting prize: $e");
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
                        item['prize_name'] ?? '',
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
                  '${DateTime.parse(item['date_of_receipt']).month} / ${DateTime.parse(item['date_of_receipt']).year}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
      modalContent: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        child: PrizeModal(
          onUpdate: (prize) async {
            final response = await PrizeServices.createPrize(prize);
            if (response['statusCode'] == 201) {
              getPrizeOfCandidate();
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
