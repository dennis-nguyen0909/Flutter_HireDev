import 'package:flutter/material.dart';
import 'package:hiredev/models/CourseModel.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:provider/provider.dart';

class CourseModal extends StatefulWidget {
  @override
  _CourseModalState createState() => _CourseModalState();
}

class _CourseModalState extends State<CourseModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _organizationController = TextEditingController();
  final _certificateUrlController = TextEditingController();
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      // final response = await ProfileServices.getCourses(user?.id ?? '');
      // if (response['statusCode'] == 200) {
      //   setState(() {
      //     _courses =
      //         (response['data'] as List)
      //             .map((item) => CourseModel.fromJson(item))
      //             .toList();
      //   });
      // }
    } catch (e) {
      print('Error loading courses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = context.read<UserProvider>().user;
        final course = CourseModel(
          name: _nameController.text,
          description: _descriptionController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          organization: _organizationController.text,
          certificateUrl: _certificateUrlController.text,
          userId: user?.id,
        );

        // final response = await ProfileServices.createCourse(course.toJson());
        // if (response['statusCode'] == 201) {
        //   _loadCourses();
        //   _clearForm();
        //   ScaffoldMessenger.of(
        //     context,
        //   ).showSnackBar(SnackBar(content: Text('Course added successfully')));
        // }
      } catch (e) {
        print('Error saving course: $e');
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _organizationController.clear();
    _certificateUrlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses & Training'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildCourseForm(),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return ListTile(
                    title: Text(course.name ?? ''),
                    subtitle: Text(
                      '${course.organization} - ${course.startDate} to ${course.endDate}',
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

  Widget _buildCourseForm() {
    return AlertDialog(
      title: Text('Add Course/Training'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Course Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter course name';
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
                controller: _organizationController,
                decoration: InputDecoration(labelText: 'Organization'),
              ),
              TextFormField(
                controller: _certificateUrlController,
                decoration: InputDecoration(labelText: 'Certificate URL'),
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
            _saveCourse();
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
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _organizationController.dispose();
    _certificateUrlController.dispose();
    super.dispose();
  }
}
