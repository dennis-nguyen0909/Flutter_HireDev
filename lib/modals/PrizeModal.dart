import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/PrizeServices.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class PrizeModal extends StatefulWidget {
  final dynamic prize;
  final Function(dynamic)? onUpdate;
  PrizeModal({this.prize, this.onUpdate});
  @override
  _PrizeModalState createState() => _PrizeModalState();
}

class _PrizeModalState extends State<PrizeModal> {
  DateTime? _date;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _organizationController = TextEditingController();
  TextEditingController _linkController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.prize != null) {
      isEditing = true;
      _nameController.text = widget.prize['prize_name'] ?? '';
      _organizationController.text = widget.prize['organization_name'] ?? '';
      _linkController.text = widget.prize['prize_link'] ?? '';
      _date =
          widget.prize['date_of_receipt'] != null
              ? DateTime.parse(widget.prize['date_of_receipt'])
              : null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> onSubmit() async {
    try {
      setState(() {
        isLoading = true;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (_nameController.text.isEmpty ||
          _organizationController.text.isEmpty) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Vui lòng điền đầy đủ thông tin'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (_date == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Vui lòng chọn ngày nhận giải'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (user == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Lỗi'),
                content: Text('Không thể xác định thông tin người dùng'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final params = {
        'prize_name': _nameController.text,
        'organization_name': _organizationController.text,
        'date_of_receipt': _date!.toIso8601String(),
        'prize_link':
            _linkController.text.isNotEmpty ? _linkController.text : null,
        'prize_image': null,
        'user_id': user.id,
      };

      if (isEditing) {
        if (widget.onUpdate != null) {
          params['_id'] = widget.prize['_id'];
          await widget.onUpdate!(params);
        } else {
          throw Exception("Update callback is null");
        }
      } else {
        final response = await PrizeServices.createPrize(params);
        print("response: ${response['statusCode']}");
        if (response['statusCode'] == 201) {
          if (widget.onUpdate != null) {
            widget.onUpdate!(params);
          }
        }
      }
    } catch (e) {
      print("Error submitting prize: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin giải thưởng: ${e.toString()}',
              ),
            ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing
                            ? 'Chỉnh sửa giải thưởng'
                            : 'Thêm giải thưởng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.black87,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Tên giải thưởng',
                    hint: 'Bắt buộc',
                    controller: _nameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Tổ chức trao giải',
                    hint: 'Bắt buộc',
                    controller: _organizationController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày nhận giải',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _date == null
                            ? 'mm / yyyy'
                            : '${_date!.month} / ${_date!.year}',
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Liên kết",
                    hint: "Liên kết đến giải thưởng (không bắt buộc)",
                    controller: _linkController,
                    type: InputType.input,
                    required: false,
                  ),
                  SizedBox(height: 24),
                  ButtonCustom(
                    text: isEditing ? "Cập nhật" : "Lưu",
                    onPressed: () {
                      onSubmit();
                    },
                    backgroundColor: AppColors.primaryColor,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
