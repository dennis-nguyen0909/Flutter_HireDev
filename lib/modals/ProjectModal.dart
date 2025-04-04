import 'package:flutter/material.dart';
import 'package:hiredev/models/ProjectModel.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:provider/provider.dart';

class ProjectModal extends StatefulWidget {
  @override
  _ProjectModalState createState() => _ProjectModalState();
}

class _ProjectModalState extends State<ProjectModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _roleController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _technologiesController = TextEditingController();
  List<ProjectModel> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      // final response = await ProfileServices.getProjects(user?.id ?? '');
      // if (response['statusCode'] == 200) {
      //   setState(() {
      //     _projects =
      //         (response['data'] as List)
      //             .map((item) => ProjectModel.fromJson(item))
      //             .toList();
      //   });
      // }
    } catch (e) {
      print('Error loading projects: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = context.read<UserProvider>().user;
        final project = ProjectModel(
          name: _nameController.text,
          description: _descriptionController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          role: _roleController.text,
          technologies:
              _technologiesController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList(),
          projectUrl: _projectUrlController.text,
          userId: user?.id,
        );

        // final response = await ProfileServices.createProject(project.toJson());
        // if (response['statusCode'] == 201) {
        //   _loadProjects();
        //   _clearForm();
        //   ScaffoldMessenger.of(
        //     context,
        //   ).showSnackBar(SnackBar(content: Text('Project added successfully')));
        // }
      } catch (e) {
        print('Error saving project: $e');
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _roleController.clear();
    _projectUrlController.clear();
    _technologiesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildProjectForm(),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _projects.length,
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  return ListTile(
                    title: Text(project.name ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Role: ${project.role}'),
                        Text(
                          'Technologies: ${project.technologies?.join(', ')}',
                        ),
                        Text('${project.startDate} to ${project.endDate}'),
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

  Widget _buildProjectForm() {
    return AlertDialog(
      title: Text('Add Project'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter project name';
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
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Your Role'),
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
                controller: _technologiesController,
                decoration: InputDecoration(
                  labelText: 'Technologies (comma separated)',
                  hintText: 'React, Node.js, MongoDB',
                ),
              ),
              TextFormField(
                controller: _projectUrlController,
                decoration: InputDecoration(labelText: 'Project URL'),
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
            _saveProject();
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
    _roleController.dispose();
    _projectUrlController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }
}
