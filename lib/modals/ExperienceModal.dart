import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class ExperienceModal extends StatefulWidget {
  final dynamic experience;
  final Function(dynamic)? onUpdate;
  ExperienceModal({this.experience, this.onUpdate});
  @override
  _ExperienceModalState createState() => _ExperienceModalState();
}

class _ExperienceModalState extends State<ExperienceModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _positionController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _responsibilitiesController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      isEditing = true;
      _companyNameController.text = widget.experience['company_name'] ?? '';
      _positionController.text = widget.experience['position'] ?? '';
      _descriptionController.text = widget.experience['description'] ?? '';
      _locationController.text = widget.experience['location'] ?? '';
      _responsibilitiesController.text =
          widget.experience['responsibilities']?.join('\n') ?? '';
      _startDate =
          widget.experience['start_date'] != null
              ? DateTime.parse(widget.experience['start_date'])
              : null;
      _endDate =
          widget.experience['end_date'] != null
              ? DateTime.parse(widget.experience['end_date'])
              : null;
      _isCurrent = widget.experience['is_current'] ?? false;
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

      if (_companyNameController.text.isEmpty ||
          _positionController.text.isEmpty ||
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

      if (!_isCurrent && _endDate == null) {
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
        'company_name': _companyNameController.text,
        'position': _positionController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'responsibilities':
            _responsibilitiesController.text
                .split('\n')
                .where((e) => e.isNotEmpty)
                .toList(),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _isCurrent ? null : _endDate?.toIso8601String(),
        'is_current': _isCurrent,
        'user_id': user!.id,
      };

      if (isEditing) {
        params['_id'] = widget.experience['_id'];
        await widget.onUpdate!(params);
      } else {
        final response = await ApiService().post(
          dotenv.env['API_URL']! + "experiences",
          params,
          token: await SecureStorageService().getRefreshToken(),
        );
        if (response['statusCode'] == 201) {
          widget.onUpdate!(params);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error submitting experience: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin kinh nghiệm: ${e.toString()}',
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
                            ? 'Chỉnh sửa kinh nghiệm'
                            : 'Thêm kinh nghiệm',
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
                    label: 'Tên công ty',
                    hint: 'Bắt buộc',
                    controller: _companyNameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Vị trí',
                    hint: 'Bắt buộc',
                    controller: _positionController,
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
                              _isCurrent
                                  ? null
                                  : () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
                              border: OutlineInputBorder(),
                              enabled: !_isCurrent,
                            ),
                            child: Text(
                              _isCurrent
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
                        value: _isCurrent,
                        onChanged: (value) {
                          setState(() {
                            _isCurrent = value ?? false;
                          });
                        },
                      ),
                      Text('Đang làm việc'),
                    ],
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Địa điểm",
                    hint: "Địa điểm làm việc",
                    controller: _locationController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Mô tả",
                    hint: "Mô tả về công việc",
                    controller: _descriptionController,
                    type: InputType.textarea,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  // CustomInput(
                  //   label: "Nhiệm vụ",
                  //   hint: "Các nhiệm vụ chính (mỗi nhiệm vụ một dòng)",
                  //   controller: _responsibilitiesController,
                  //   type: InputType.textarea,
                  //   required: true,
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
    _companyNameController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }
}
