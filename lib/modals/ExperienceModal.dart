import 'package:flutter/material.dart';
import 'package:hiredev/models/ExperienceModel.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:provider/provider.dart';

class ExperienceModal extends StatefulWidget {
  @override
  _ExperienceModalState createState() => _ExperienceModalState();
}

class _ExperienceModalState extends State<ExperienceModal> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  bool _isCurrent = false;
  List<ExperienceModel> _experiences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future<void> _loadExperiences() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      // final response = await ProfileServices.getExperiences(user?.id ?? '');
      // if (response['statusCode'] == 200) {
      //   setState(() {
      //     _experiences =
      //         (response['data'] as List)
      //             .map((item) => ExperienceModel.fromJson(item))
      //             .toList();
      //   });
      // }
    } catch (e) {
      print('Error loading experiences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveExperience() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = context.read<UserProvider>().user;
        final experience = ExperienceModel(
          companyName: _companyNameController.text,
          position: _positionController.text,
          description: _descriptionController.text,
          startDate: _startDateController.text,
          endDate: _isCurrent ? null : _endDateController.text,
          isCurrent: _isCurrent,
          location: _locationController.text,
          responsibilities: _responsibilitiesController.text.split('\n'),
          userId: user?.id,
        );

        // final response = await ProfileServices.createExperience(
        //   experience.toJson(),
        // );
        // if (response['statusCode'] == 201) {
        //   _loadExperiences();
        //   _clearForm();
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Experience added successfully')),
        //   );
        // }
      } catch (e) {
        print('Error saving experience: $e');
      }
    }
  }

  void _clearForm() {
    _companyNameController.clear();
    _positionController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _locationController.clear();
    _responsibilitiesController.clear();
    setState(() => _isCurrent = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Experience'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildExperienceForm(),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _experiences.length,
                itemBuilder: (context, index) {
                  final experience = _experiences[index];
                  return ListTile(
                    title: Text(experience.position ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(experience.companyName ?? ''),
                        Text(experience.location ?? ''),
                        Text(
                          '${experience.startDate} - ${experience.isCurrent == true ? 'Present' : experience.endDate}',
                        ),
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

  Widget _buildExperienceForm() {
    return AlertDialog(
      title: Text('Add Work Experience'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(labelText: 'Company Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Position'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter position';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _startDateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isCurrent,
                    onChanged: (value) {
                      setState(() => _isCurrent = value ?? false);
                    },
                  ),
                  Text('I currently work here'),
                ],
              ),
              if (!_isCurrent)
                TextFormField(
                  controller: _endDateController,
                  decoration: InputDecoration(labelText: 'End Date'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _endDateController.text = date.toString().split(' ')[0];
                    }
                  },
                ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _responsibilitiesController,
                decoration: InputDecoration(
                  labelText: 'Responsibilities (one per line)',
                  hintText: 'Responsibility 1\nResponsibility 2',
                ),
                maxLines: 5,
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
            _saveExperience();
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _locationController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }
}
