import 'package:flutter/material.dart';
import 'package:hiredev/models/CertificateModel.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:provider/provider.dart';

class CertificateModal extends StatefulWidget {
  @override
  _CertificateModalState createState() => _CertificateModalState();
}

class _CertificateModalState extends State<CertificateModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _credentialIdController = TextEditingController();
  final _credentialUrlController = TextEditingController();
  List<CertificateModel> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    try {
      // final user = context.read<UserProvider>().user;
      // final response = await ProfileServices.getCertificates(user?.id ?? '');
      // if (response['statusCode'] == 200) {
      //   setState(() {
      //     _certificates =
      //         (response['data'] as List)
      //             .map((item) => CertificateModel.fromJson(item))
      //             .toList();
      //   });
      // }
    } catch (e) {
      print('Error loading certificates: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCertificate() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = context.read<UserProvider>().user;
        final certificate = CertificateModel(
          name: _nameController.text,
          organization: _organizationController.text,
          issueDate: _issueDateController.text,
          expiryDate: _expiryDateController.text,
          credentialId: _credentialIdController.text,
          credentialUrl: _credentialUrlController.text,
          userId: user?.id,
        );

        // final response = await ProfileServices.createCertificate(
        //   certificate.toJson(),
        // );
        // if (response['statusCode'] == 201) {
        //   _loadCertificates();
        //   _clearForm();
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Certificate added successfully')),
        //   );
        // }
      } catch (e) {
        print('Error saving certificate: $e');
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _organizationController.clear();
    _issueDateController.clear();
    _expiryDateController.clear();
    _credentialIdController.clear();
    _credentialUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificates'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildCertificateForm(),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _certificates.length,
                itemBuilder: (context, index) {
                  final certificate = _certificates[index];
                  return ListTile(
                    title: Text(certificate.name ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(certificate.organization ?? ''),
                        Text('Issued: ${certificate.issueDate}'),
                        if (certificate.expiryDate != null)
                          Text('Expires: ${certificate.expiryDate}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Implement edit functionality
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Implement delete functionality
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildCertificateForm() {
    return AlertDialog(
      title: Text('Add Certificate'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Certificate Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter certificate name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _organizationController,
                decoration: InputDecoration(labelText: 'Issuing Organization'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter organization name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _issueDateController,
                decoration: InputDecoration(labelText: 'Issue Date'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _issueDateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (Optional)',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _expiryDateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              TextFormField(
                controller: _credentialIdController,
                decoration: InputDecoration(labelText: 'Credential ID'),
              ),
              TextFormField(
                controller: _credentialUrlController,
                decoration: InputDecoration(labelText: 'Credential URL'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _saveCertificate();
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _credentialIdController.dispose();
    _credentialUrlController.dispose();
    super.dispose();
  }
}
