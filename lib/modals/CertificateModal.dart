import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/colors/colors.dart';
import 'package:hiredev/components/ButtonCustom/ButtonCustom.dart';
import 'package:hiredev/components/CustomInput/CustomInput.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:hiredev/services/apiServices.dart';
import 'package:hiredev/utils/secure_storage_service.dart';
import 'package:provider/provider.dart';

class CertificateModal extends StatefulWidget {
  final dynamic certificate;
  final Function(dynamic)? onUpdate;
  final Function(dynamic)? onCreate;
  CertificateModal({this.certificate, this.onUpdate, this.onCreate});
  @override
  _CertificateModalState createState() => _CertificateModalState();
}

class _CertificateModalState extends State<CertificateModal> {
  DateTime? _issueDate;
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _organizationController = TextEditingController();
  TextEditingController _credentialIdController = TextEditingController();
  TextEditingController _credentialUrlController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;
  bool _isNoExpiry = false;

  @override
  void initState() {
    super.initState();
    if (widget.certificate != null) {
      isEditing = true;
      _nameController.text = widget.certificate['certificate_name'] ?? '';
      _organizationController.text =
          widget.certificate['organization_name'] ?? '';
      _credentialIdController.text = widget.certificate['credential_id'] ?? '';
      _credentialUrlController.text =
          widget.certificate['link_certificate'] ?? '';
      _issueDate =
          widget.certificate['issue_date'] != null
              ? DateTime.parse(widget.certificate['issue_date'])
              : null;
      _startDate =
          widget.certificate['start_date'] != null
              ? DateTime.parse(widget.certificate['start_date'])
              : null;
      _endDate =
          widget.certificate['end_date'] != null
              ? DateTime.parse(widget.certificate['end_date'])
              : null;
      _isNoExpiry = _endDate == null;
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isIssueDate, {
    bool isStartDate = false,
    bool isEndDate = false,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: isIssueDate ? DateTime.now() : DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else if (isStartDate) {
          _startDate = picked;
        } else if (isEndDate) {
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
          _organizationController.text.isEmpty) {
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

      if (!_isNoExpiry && _endDate == null) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Vui lòng chọn ngày hết hạn'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (_endDate != null &&
          _startDate != null &&
          _endDate!.isBefore(_startDate!)) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Thông báo'),
                content: Text('Ngày hết hạn không thể trước ngày cấp'),
              ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (!_isNoExpiry &&
          _endDate != null &&
          _startDate != null &&
          _endDate!.isBefore(_startDate!)) {
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
        'candidate_id': "67e74c5cf5890770fa4b7189",
        'certificate_name': _nameController.text,
        'organization_name': _organizationController.text,
        'start_date': _startDate != null ? _startDate!.toIso8601String() : null,
        'end_date':
            _isNoExpiry
                ? null
                : (_endDate != null ? _endDate!.toIso8601String() : null),
        'link_certificate':
            _credentialUrlController.text.isNotEmpty
                ? _credentialUrlController.text
                : null,
        'img_certificate': null,
        'is_not_expired': _isNoExpiry,
      };

      if (isEditing) {
        params['_id'] = widget.certificate['_id'];
        await widget.onUpdate!(params);
      } else {
        await widget.onCreate!(params);
      }
    } catch (e) {
      print("Error submitting certificate: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Lỗi'),
              content: Text(
                'Đã xảy ra lỗi khi lưu thông tin chứng chỉ: ${e.toString()}',
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
                        isEditing ? 'Chỉnh sửa chứng chỉ' : 'Thêm chứng chỉ',
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
                    label: 'Tên chứng chỉ',
                    hint: 'Bắt buộc',
                    controller: _nameController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  CustomInput(
                    label: 'Tên tổ chức',
                    hint: 'Bắt buộc',
                    controller: _organizationController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: _isNoExpiry,
                        onChanged: (value) {
                          setState(() {
                            _isNoExpiry = value ?? false;
                            if (_isNoExpiry) {
                              _endDate = null;
                            }
                          });
                        },
                      ),
                      Text('Vô hạn'),
                    ],
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, false, isStartDate: true),
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
                  SizedBox(height: 16),
                  if (!_isNoExpiry) ...[
                    InkWell(
                      onTap: () => _selectDate(context, false, isEndDate: true),
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
                    SizedBox(height: 16),
                  ],

                  CustomInput(
                    label: "Liên kết chứng chỉ",
                    hint: "Liên kết đến chứng chỉ (không bắt buộc)",
                    controller: _credentialUrlController,
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
    _credentialIdController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }
}
