import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/EducationServices.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class EducationModal extends StatefulWidget {
  final dynamic education;
  final Function(dynamic)? onUpdate;
  final Function(dynamic)? onCreate;
  EducationModal({this.education, this.onUpdate, this.onCreate});
  @override
  _EducationModalState createState() => _EducationModalState();
}

class _EducationModalState extends State<EducationModal> {
  String? _selectedDegree;
  DateTime? _fromDate;
  DateTime? _toDate;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _schoolController = TextEditingController();
  TextEditingController _majorController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;
  bool _currentlyStudying = false;

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      isEditing = true;
      _schoolController.text = widget.education['school'] ?? '';
      _majorController.text = widget.education['major'] ?? '';
      _descriptionController.text = widget.education['description'] ?? '';
      _fromDate =
          widget.education['start_date'] != null
              ? DateTime.parse(widget.education['start_date'])
              : null;
      _toDate =
          widget.education['end_date'] != null
              ? DateTime.parse(widget.education['end_date'])
              : null;
      _currentlyStudying = widget.education['currently_studying'] ?? false;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
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

      // Validate all required fields
      if (_schoolController.text.isEmpty ||
          _majorController.text.isEmpty ||
          _descriptionController.text.isEmpty) {
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

      if (_fromDate == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Vui lòng chọn ngày bắt đầu'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (!_currentlyStudying && _toDate == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Vui lòng chọn ngày kết thúc'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (_toDate != null &&
          _fromDate != null &&
          _toDate!.isBefore(_fromDate!)) {
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
        'currently_studying': _currentlyStudying,
        'description': _descriptionController.text,
        'major': _majorController.text,
        'school': _schoolController.text,
        'start_date':
            _fromDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'end_date': _currentlyStudying ? null : _toDate?.toIso8601String(),
        'user_id': user.id,
      };

      // Check if both callbacks are provided
      if (isEditing && widget.onUpdate != null) {
        params['_id'] = widget.education['_id'];
        await widget.onUpdate!(params);
      } else if (!isEditing && widget.onCreate != null) {
        print("createEducation: $params");
        print("widget.onCreate: ${widget.onCreate}");
        await widget.onCreate!(params);
      } else {
        // Show a more user-friendly error message
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Lỗi hệ thống'),
                content: Text(
                  'Không thể lưu thông tin học vấn. Vui lòng thử lại sau.',
                ),
              ),
        );
        print(
          "Missing callback: isEditing=$isEditing, onUpdate=${widget.onUpdate != null}, onCreate=${widget.onCreate != null}",
        );
        return;
      }
    } catch (e) {
      print("Error submitting education: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin học vấn: ${e.toString()}',
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
              // Thêm ConstrainedBox để giới hạn chiều cao
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.8, // Chiếm 80% chiều cao màn hình
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Chỉnh sửa học vấn' : 'Thêm học vấn',
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
                    label: 'Trường học',
                    hint: 'Bắt buộc',
                    controller: _schoolController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Chuyên ngành',
                    hint: 'Bắt buộc',
                    controller: _majorController,
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
                              _fromDate == null
                                  ? 'mm / yyyy'
                                  : '${_fromDate!.month} / ${_fromDate!.year}',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap:
                              _currentlyStudying
                                  ? null
                                  : () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
                              border: OutlineInputBorder(),
                              enabled: !_currentlyStudying,
                            ),
                            child: Text(
                              _currentlyStudying
                                  ? 'Hiện tại'
                                  : _toDate == null
                                  ? 'mm / yyyy'
                                  : '${_toDate!.month} / ${_toDate!.year}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _currentlyStudying,
                        onChanged: (value) {
                          setState(() {
                            _currentlyStudying = value ?? false;
                          });
                        },
                      ),
                      Text('Đang học'),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Mô tả",
                    hint: "Mô tả",
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
}
