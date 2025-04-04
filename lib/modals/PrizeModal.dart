import 'package:flutter/material.dart';
import 'package:hiredev/models/PrizeModel.dart';
import 'package:hiredev/services/profileServices.dart';
import 'package:hiredev/provider/user_provider.dart';
import 'package:provider/provider.dart';

class PrizeModal extends StatefulWidget {
  @override
  _PrizeModalState createState() => _PrizeModalState();
}

class _PrizeModalState extends State<PrizeModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _organizationController = TextEditingController();
  List<PrizeModel> _prizes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrizes();
  }

  Future<void> _loadPrizes() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      // final response = await ProfileServices.getPrizes(user?.id ?? '');
      // if (response['statusCode'] == 200) {
      //   setState(() {
      //     _prizes =
      //         (response['data'] as List)
      //             .map((item) => PrizeModel.fromJson(item))
      //             .toList();
      //   });
      // }
    } catch (e) {
      print('Error loading prizes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePrize() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final user = context.read<UserProvider>().user;
        final prize = PrizeModel(
          name: _nameController.text,
          description: _descriptionController.text,
          date: _dateController.text,
          organization: _organizationController.text,
          userId: user?.id,
        );

        // final response = await ProfileServices.createPrize(prize.toJson());
        // if (response['statusCode'] == 201) {
        //   _loadPrizes();
        //   _clearForm();
        //   ScaffoldMessenger.of(
        //     context,
        //   ).showSnackBar(SnackBar(content: Text('Prize added successfully')));
        // }
      } catch (e) {
        print('Error saving prize: $e');
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _organizationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prizes & Awards'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildPrizeForm(),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _prizes.length,
                itemBuilder: (context, index) {
                  final prize = _prizes[index];
                  return ListTile(
                    title: Text(prize.name ?? ''),
                    subtitle: Text('${prize.organization} - ${prize.date}'),
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

  Widget _buildPrizeForm() {
    return AlertDialog(
      title: Text('Add Prize/Award'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Prize Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter prize name';
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
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _dateController.text = date.toString().split(' ')[0];
                  }
                },
              ),
              TextFormField(
                controller: _organizationController,
                decoration: InputDecoration(labelText: 'Organization'),
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
            _savePrize();
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
    _dateController.dispose();
    _organizationController.dispose();
    super.dispose();
  }
}
