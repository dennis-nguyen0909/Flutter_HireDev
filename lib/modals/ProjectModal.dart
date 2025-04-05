import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class ProjectModal extends StatefulWidget {
  final dynamic project;
  final Function(dynamic)? onUpdate;
  ProjectModal({this.project, this.onUpdate});
  @override
  _ProjectModalState createState() => _ProjectModalState();
}

class _ProjectModalState extends State<ProjectModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _roleController = TextEditingController();
  TextEditingController _technologiesController = TextEditingController();
  TextEditingController _projectUrlController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;
  bool _currentlyWorking = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      isEditing = true;
      _nameController.text = widget.project['name'] ?? '';
      _descriptionController.text = widget.project['description'] ?? '';
      _roleController.text = widget.project['role'] ?? '';
      _technologiesController.text =
          widget.project['technologies']?.join(', ') ?? '';
      _projectUrlController.text = widget.project['project_url'] ?? '';
      _startDate =
          widget.project['start_date'] != null
              ? DateTime.parse(widget.project['start_date'])
              : null;
      _endDate =
          widget.project['end_date'] != null
              ? DateTime.parse(widget.project['end_date'])
              : null;
      _currentlyWorking = widget.project['currently_working'] ?? false;
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

      if (_nameController.text.isEmpty ||
          _roleController.text.isEmpty ||
          _startDate == null) {
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

      if (!_currentlyWorking && _endDate == null) {
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

      if (_endDate != null && _endDate!.isBefore(_startDate!)) {
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
        'name': _nameController.text,
        'description': _descriptionController.text,
        'role': _roleController.text,
        'technologies':
            _technologiesController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _currentlyWorking ? null : _endDate?.toIso8601String(),
        'currently_working': _currentlyWorking,
        'project_url':
            _projectUrlController.text.isNotEmpty
                ? _projectUrlController.text
                : null,
        'user_id': user!.id,
      };

      if (isEditing) {
        params['_id'] = widget.project['_id'];
        await widget.onUpdate!(params);
      } else {
        final response = await ApiService().post(
          dotenv.env['API_URL']! + "projects",
          params,
          token: await SecureStorageService().getRefreshToken(),
        );
        if (response['statusCode'] == 201) {
          widget.onUpdate!(params);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error submitting project: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin dự án: ${e.toString()}',
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
                        isEditing ? 'Chỉnh sửa dự án' : 'Thêm dự án',
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
                    label: 'Tên dự án',
                    hint: 'Bắt buộc',
                    controller: _nameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Vai trò',
                    hint: 'Bắt buộc',
                    controller: _roleController,
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
                          onTap:
                              _currentlyWorking
                                  ? null
                                  : () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
                              border: OutlineInputBorder(),
                              enabled: !_currentlyWorking,
                            ),
                            child: Text(
                              _currentlyWorking
                                  ? 'Hiện tại'
                                  : _endDate == null
                                  ? 'mm / yyyy'
                                  : '${_endDate!.month} / ${_endDate!.year}',
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
                        value: _currentlyWorking,
                        onChanged: (value) {
                          setState(() {
                            _currentlyWorking = value ?? false;
                          });
                        },
                      ),
                      Text('Đang thực hiện'),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Mô tả",
                    hint: "Mô tả về dự án",
                    controller: _descriptionController,
                    type: InputType.textarea,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Công nghệ sử dụng",
                    hint:
                        "Các công nghệ sử dụng trong dự án (cách nhau bởi dấu phẩy)",
                    controller: _technologiesController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  // Padding(
                  //   padding: EdgeInsets.only(bottom: 30),
                  //   child: CustomInput(
                  //     label: "Liên kết dự án",
                  //     hint: "Liên kết đến dự án (không bắt buộc)",
                  //     controller: _projectUrlController,
                  //     type: InputType.input,
                  //     required: false,
                  //   ),
                  // ),
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
    _roleController.dispose();
    _technologiesController.dispose();
    _projectUrlController.dispose();
    super.dispose();
  }
}
