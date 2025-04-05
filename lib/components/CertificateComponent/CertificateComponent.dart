import 'package:flutter/material.dart';
import 'package:hiredev/components/Section/Section.dart';
import 'package:hiredev/modals/CertificateModal.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/CertificateServices.dart';
import 'package:provider/provider.dart';

class CertificateComponent extends StatefulWidget {
  @override
  _CertificateComponentState createState() => _CertificateComponentState();
}

class _CertificateComponentState extends State<CertificateComponent> {
  List<dynamic> certificates = [];
  @override
  void initState() {
    super.initState();
    getCertificatesOfCandidate(current: 1, pageSize: 10);
  }

  Future<void> getCertificatesOfCandidate({
    int current = 1,
    int pageSize = 10,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final response = await CertificateServices.getCertificatesByUserToken(
      current: current,
      pageSize: pageSize,
      userId: user?.id,
    );
    print("getCertificatesOfCandidate: $response");
    if (response['statusCode'] == 200) {
      setState(() {
        certificates = response['data']['items'];
      });
    }
  }

  Future<void> onUpdateCertificate(dynamic certificate) async {
    final response = await CertificateServices.updateCertificate(
      certificate['_id'],
      certificate,
    );
    if (response['statusCode'] == 200) {
      getCertificatesOfCandidate();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionComponent(
      title: 'Chứng chỉ',
      description:
          'Thể hiện những chứng chỉ bạn đã đạt được cho công việc của mình.',
      items: certificates,
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
                                child: CertificateModal(
                                  certificate: item,
                                  onUpdate: onUpdateCertificate,
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
                                  'Bạn có chắc chắn muốn xóa chứng chỉ này?',
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
                                        await CertificateServices.deleteCertificate(
                                          item['_id'],
                                        );
                                        getCertificatesOfCandidate();
                                      } catch (e) {
                                        print("Error deleting certificate: $e");
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
                  item['organization'] ?? '',
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 4.0),
                Text(
                  '${DateTime.parse(item['issue_date']).month} / ${DateTime.parse(item['issue_date']).year}${item['expiry_date'] != null ? ' - ${DateTime.parse(item['expiry_date']).month} / ${DateTime.parse(item['expiry_date']).year}' : ''}',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
      modalContent: Container(
        height: MediaQuery.of(context).size.height * 0.94,
        child: CertificateModal(
          onUpdate: (certificate) async {
            final response = await CertificateServices.createCertificate(
              certificate,
            );
            if (response['statusCode'] == 201) {
              getCertificatesOfCandidate();
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
