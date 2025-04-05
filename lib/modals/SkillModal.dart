import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/SkillServices.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class SkillModal extends StatefulWidget {
  final dynamic skill;
  final Function(dynamic)? onUpdate;
  final Function(dynamic)? onCreate;
  SkillModal({this.skill, this.onUpdate, this.onCreate});
  @override
  _SkillModalState createState() => _SkillModalState();
}

class _SkillModalState extends State<SkillModal> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  double _evaluate = 1.5;
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      isEditing = true;
      _nameController.text = widget.skill['name'] ?? '';
      _descriptionController.text = widget.skill['description'] ?? '';
      _evaluate = widget.skill['evalute']?.toDouble() ?? 1.5;
    }
  }

  Future<void> onSubmit() async {
    try {
      setState(() {
        isLoading = true;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
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

      if (user == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Lỗi'),
                content: Text('Không tìm thấy thông tin người dùng'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final params = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'evalute': _evaluate,
        'user_id': user.id,
      };

      if (isEditing && widget.onUpdate != null) {
        params['_id'] = widget.skill['_id'];
        await widget.onUpdate!(params);
      } else if (!isEditing && widget.onCreate != null) {
        await widget.onCreate!(params);
      } else {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Lỗi hệ thống'),
                content: Text(
                  'Không thể lưu thông tin kỹ năng. Vui lòng thử lại sau.',
                ),
              ),
        );
        return;
      }
    } catch (e) {
      print("Error submitting skill: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin kỹ năng: ${e.toString()}',
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
                        isEditing ? 'Chỉnh sửa kỹ năng' : 'Thêm kỹ năng',
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
                    label: 'Tên kỹ năng',
                    hint: 'Bắt buộc',
                    controller: _nameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  Text('Đánh giá kỹ năng'),
                  Slider(
                    value: _evaluate,
                    min: 1,
                    max: 5,
                    divisions: 8,
                    label: _evaluate.toString(),
                    onChanged: (value) {
                      setState(() {
                        _evaluate = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Mô tả",
                    hint: "Mô tả kỹ năng",
                    controller: _descriptionController,
                    type: InputType.textarea,
                    required: true,
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
    _descriptionController.dispose();
    super.dispose();
  }
}
