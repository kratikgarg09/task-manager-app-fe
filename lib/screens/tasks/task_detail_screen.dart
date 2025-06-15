import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime dueDate;
  late DateTime? reminderDate;
  bool loading = false;
  String message = '';
  String selectedPriority = 'MEDIUM';
  String selectedStatus = 'PENDING';

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    dueDate = widget.task.dueDate;
    reminderDate = widget.task.reminderDate;
    selectedStatus = widget.task.status ?? "PENDING";
    selectedPriority = widget.task.priority ?? "MEDIUM";
  }

  Future<void> _updateTask() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.put(
      Uri.parse('http://localhost:8080/api/tasks/${widget.task.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': titleController.text,
        'description': descriptionController.text,
        'dueDate': dueDate.toIso8601String(),
        'reminderTime': reminderDate?.toIso8601String(),
        'status': widget.task.status,
        'priority': selectedPriority,
        'status': selectedStatus,
      }),
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      setState(() => message = 'Failed to update task');
    }
  }

  Future<void> _deleteTask() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/tasks/${widget.task.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      setState(() => message = 'Failed to delete task');
    }
  }

  Future<void> _pickDate(bool isReminder) async {
    final date = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      if (isReminder) {
        setState(() => reminderDate = date);
      } else {
        setState(() => dueDate = date);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Due Date: ${dateFormat.format(dueDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(false),
            ),
            ListTile(
              title: Text(reminderDate == null
                  ? 'Set Reminder Date'
                  : 'Reminder Date: ${dateFormat.format(reminderDate!)}'),
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
            const SizedBox(height: 16),
            if (message.isNotEmpty) Text(message, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: loading ? null : _updateTask, child: const Text('Update Task')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loading ? null : _deleteTask,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Task'),
            ),
          ],
        ),
      ),
    );
  }
}
