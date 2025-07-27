import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';


class TaskFilterScreen extends StatefulWidget {
  const TaskFilterScreen({super.key});

  @override
  State<TaskFilterScreen> createState() => _TaskFilterScreenState();
}

class _TaskFilterScreenState extends State<TaskFilterScreen> {
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final tagsController = TextEditingController();
  String? selectedStatus;
  DateTime? fromDate;
  DateTime? toDate;

  List<Task> filteredTasks = [];



  void _searchTasks() async {
    final results = await TaskService.searchTasks(
      title: titleController.text,
      status: selectedStatus,
      category: categoryController.text,
      tags:tagsController.text,
      fromDate: fromDate,
      toDate: toDate,
    );
    setState(() => filteredTasks = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(labelText: 'Tags'),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              hint: const Text("Select Status"),
              isExpanded: true,
              items: ['PENDING','IN_PROGRESS', 'COMPLETED'].map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) => setState(() => selectedStatus = val),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: fromDate ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          fromDate = date;
                          // 👇 Reset toDate if it's before new fromDate
                          if (toDate != null && toDate!.isBefore(fromDate!)) {
                            toDate = null;
                          }
                        });
                      }
                    },
                    child: Text("From: ${fromDate?.toLocal().toIso8601String().split('T').first ?? 'Not set'}"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: toDate ?? fromDate ?? DateTime.now(),
                        firstDate: fromDate ?? DateTime(2023),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => toDate = date);
                      }
                    },
                    child: Text("To: ${toDate?.toLocal().toIso8601String().split('T').first ?? 'Not set'}"),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _searchTasks,
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.status.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
