import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class CourseModal extends StatefulWidget {
  final dynamic course;
  final Function(dynamic)? onUpdate;
  final Function(dynamic)? onCreate;
  CourseModal({this.course, this.onUpdate, this.onCreate});
  @override
  _CourseModalState createState() => _CourseModalState();
}

class _CourseModalState extends State<CourseModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _courseNameController = TextEditingController();
  TextEditingController _organizationNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _courseLinkController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      isEditing = true;
      _courseNameController.text = widget.course['course_name'] ?? '';
      _organizationNameController.text =
          widget.course['organization_name'] ?? '';
      _descriptionController.text = widget.course['description'] ?? '';
      _courseLinkController.text = widget.course['course_link'] ?? '';
      _startDate =
          widget.course['start_date'] != null
              ? DateTime.parse(widget.course['start_date'])
              : null;
      _endDate =
          widget.course['end_date'] != null
              ? DateTime.parse(widget.course['end_date'])
              : null;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
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

      if (_courseNameController.text.isEmpty ||
          _organizationNameController.text.isEmpty ||
          _startDate == null ||
          _endDate == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (_endDate!.isBefore(_startDate!)) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Ngày kết thúc không thể trước ngày bắt đầu'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final params = {
        'user_id': user!.id,
        'course_name': _courseNameController.text,
        'organization_name': _organizationNameController.text,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'description': _descriptionController.text,
      };

      // Only add course_link if it's not empty
      if (_courseLinkController.text.isNotEmpty) {
        params['course_link'] = _courseLinkController.text;
      }

      if (isEditing) {
        params['_id'] = widget.course['_id'];
        await widget.onUpdate!(params);
      } else {
        await widget.onCreate!(params);
      }
    } catch (e) {
      print("Error submitting course: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin khóa học: ${e.toString()}',
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
                        isEditing ? 'Chỉnh sửa khóa học' : 'Thêm khóa học',
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
                    label: 'Tên khóa học',
                    hint: 'Bắt buộc',
                    controller: _courseNameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Tổ chức đào tạo',
                    hint: 'Bắt buộc',
                    controller: _organizationNameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày bắt đầu',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _startDate == null
                                  ? 'mm / yyyy'
                                  : '${_startDate!.month} / ${_startDate!.year}',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _endDate == null
                                  ? 'mm / yyyy'
                                  : '${_endDate!.month} / ${_endDate!.year}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Mô tả",
                    hint: "Mô tả về khóa học",
                    controller: _descriptionController,
                    type: InputType.textarea,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Liên kết khóa học",
                    hint: "Liên kết đến khóa học (không bắt buộc)",
                    controller: _courseLinkController,
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
    _courseNameController.dispose();
    _organizationNameController.dispose();
    _descriptionController.dispose();
    _courseLinkController.dispose();
    super.dispose();
  }
}
