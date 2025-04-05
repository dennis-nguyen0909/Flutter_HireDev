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
  CertificateModal({this.certificate, this.onUpdate});
  @override
  _CertificateModalState createState() => _CertificateModalState();
}

class _CertificateModalState extends State<CertificateModal> {
  DateTime? _issueDate;
  DateTime? _expiryDate;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _organizationController = TextEditingController();
  TextEditingController _credentialIdController = TextEditingController();
  TextEditingController _credentialUrlController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;
  bool _hasExpiryDate = false;

  @override
  void initState() {
    super.initState();
    if (widget.certificate != null) {
      isEditing = true;
      _nameController.text = widget.certificate['name'] ?? '';
      _organizationController.text = widget.certificate['organization'] ?? '';
      _credentialIdController.text = widget.certificate['credential_id'] ?? '';
      _credentialUrlController.text =
          widget.certificate['credential_url'] ?? '';
      _issueDate =
          widget.certificate['issue_date'] != null
              ? DateTime.parse(widget.certificate['issue_date'])
              : null;
      _expiryDate =
          widget.certificate['expiry_date'] != null
              ? DateTime.parse(widget.certificate['expiry_date'])
              : null;
      _hasExpiryDate = _expiryDate != null;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
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
        } else {
          _expiryDate = picked;
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
          _organizationController.text.isEmpty ||
          _issueDate == null) {
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

      if (_hasExpiryDate && _expiryDate == null) {
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

      if (_expiryDate != null && _expiryDate!.isBefore(_issueDate!)) {
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

      final params = {
        'name': _nameController.text,
        'organization': _organizationController.text,
        'issue_date': _issueDate!.toIso8601String(),
        'expiry_date': _hasExpiryDate ? _expiryDate!.toIso8601String() : null,
        'credential_id':
            _credentialIdController.text.isNotEmpty
                ? _credentialIdController.text
                : null,
        'credential_url':
            _credentialUrlController.text.isNotEmpty
                ? _credentialUrlController.text
                : null,
        'user_id': user!.id,
      };

      if (isEditing) {
        params['_id'] = widget.certificate['_id'];
        await widget.onUpdate!(params);
      } else {
        final response = await ApiService().post(
          dotenv.env['API_URL']! + "certificates",
          params,
          token: await SecureStorageService().getRefreshToken(),
        );
        if (response['statusCode'] == 201) {
          widget.onUpdate!(params);
          Navigator.pop(context);
        }
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
                    label: 'Tổ chức cấp',
                    hint: 'Bắt buộc',
                    controller: _organizationController,
                    type: InputType.input,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Ngày cấp',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _issueDate == null
                            ? 'mm / yyyy'
                            : '${_issueDate!.month} / ${_issueDate!.year}',
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _hasExpiryDate,
                        onChanged: (value) {
                          setState(() {
                            _hasExpiryDate = value ?? false;
                            if (!_hasExpiryDate) {
                              _expiryDate = null;
                            }
                          });
                        },
                      ),
                      Text('Có ngày hết hạn'),
                    ],
                  ),
                  if (_hasExpiryDate) ...[
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày hết hạn',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _expiryDate == null
                              ? 'mm / yyyy'
                              : '${_expiryDate!.month} / ${_expiryDate!.year}',
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  CustomInput(
                    label: "Mã chứng chỉ",
                    hint: "Mã chứng chỉ (không bắt buộc)",
                    controller: _credentialIdController,
                    type: InputType.input,
                    required: false,
                  ),
                  SizedBox(height: 16),
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
