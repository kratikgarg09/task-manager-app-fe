import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? dueDate;
  DateTime? reminderDate;
  bool loading = false;
  String message = '';

  String? selectedCategory;
  List<String> selectedTags = [];
  String selectedPriority = 'MEDIUM';
  String selectedStatus = 'PENDING';

  List<dynamic> categories = [];
  List<dynamic> tags = [];

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndTags();
  }

  Future<void> fetchCategoriesAndTags() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final catRes = await http.get(
      Uri.parse('http://localhost:8080/api/categories'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final tagRes = await http.get(
      Uri.parse('http://localhost:8080/api/tags'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (catRes.statusCode == 200 && tagRes.statusCode == 200) {
      setState(() {
        categories = jsonDecode(catRes.body);
        tags = jsonDecode(tagRes.body);
      });
    }
  }

  Future<void> _submitTask() async {
    if (titleController.text.isEmpty){
      setState(() => message = 'Title is required');
      return;
    }

    if ( dueDate == null ){
      setState(() => message = 'Due Date is required');
      return;
    }

    // if ( selectedCategory == null){
    //   setState(() => message = 'Category is required');
    //   return;
    // }



    setState(() {
      loading = true;
      message = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/tasks/create'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': titleController.text,
        'description': descriptionController.text,
        'dueDate': dueDate!.toIso8601String().split('T').first,
        'reminderTime': reminderDate?.toIso8601String(),
        'priority': selectedPriority,
        'status': selectedStatus,
        'categoryId': selectedCategory != null ?  int.parse(selectedCategory!) : null,
        'tagIds': selectedTags != null ? selectedTags.map((id) => int.parse(id)).toList() : null,
      }),
    );

    setState(() => loading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      setState(() => message = 'Failed to add task');
    }
  }

  Future<void> _pickDate(bool isReminder) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isReminder) {
          reminderDate = date;
        } else {
          dueDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),

            const SizedBox(height: 16),
            ListTile(
              title: Text(dueDate == null ? 'Select Due Date' : 'Due: ${dateFormat.format(dueDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(false),
            ),
            ListTile(
              title: Text(reminderDate == null ? 'Select Reminder Date' : 'Reminder: ${dateFormat.format(reminderDate!)}'),
              trailing: const Icon(Icons.alarm),
              onTap: () => _pickDate(true),
            ),

            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: selectedPriority,
              items: ['LOW', 'MEDIUM', 'HIGH'].map((val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) => setState(() => selectedPriority = val!),
              decoration: const InputDecoration(labelText: 'Priority'),
            ),

            DropdownButtonFormField(
              value: selectedStatus,
              items: ['PENDING', 'IN_PROGRESS', 'COMPLETED'].map((val) {
                return DropdownMenuItem(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) => setState(() => selectedStatus = val!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),

            DropdownButtonFormField(
              value: selectedCategory,
              items: categories.map<DropdownMenuItem<String>>((cat) {
                return DropdownMenuItem(
                  value: cat['id'].toString(),
                  child: Text(cat['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
              decoration: const InputDecoration(labelText: 'Category'),
            ),

            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map<Widget>((tag) {
                final id = tag['id'].toString();
                final selected = selectedTags.contains(id);
                return FilterChip(
                  label: Text(tag['name']),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedTags.add(id);
                      } else {
                        selectedTags.remove(id);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.red)),

            ElevatedButton(
              onPressed: loading ? null : _submitTask,
              child: loading ? const CircularProgressIndicator() : const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}
