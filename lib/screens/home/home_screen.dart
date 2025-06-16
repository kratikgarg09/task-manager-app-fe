import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../models/task.dart';
import '../tasks/task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Task>> futureTasks;
  String selectedStatus = 'ALL';
  String selectedDue = 'ALL';

  @override
  void initState() {
    super.initState();
    futureTasks = TaskService().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          }

          List<Task> tasks = snapshot.data!;

// Apply filters
          if (selectedStatus != 'ALL') {
            tasks = tasks.where((task) => task.status?.toUpperCase() == selectedStatus).toList();
          }
          if (selectedDue != 'ALL') {
            final today = DateTime.now();
            tasks = tasks.where((task) {
              if (selectedDue == 'TODAY') {
                return task.dueDate.year == today.year &&
                    task.dueDate.month == today.month &&
                    task.dueDate.day == today.day;
              } else if (selectedDue == 'UPCOMING') {
                return task.dueDate.isAfter(today);
              }
              return true;
            }).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                        DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                        DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                        DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: selectedDue,
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Dates')),
                        DropdownMenuItem(value: 'TODAY', child: Text('Due Today')),
                        DropdownMenuItem(value: 'UPCOMING', child: Text('Upcoming')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDue = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: task.status == 'COMPLETED'
                                    ? Colors.green
                                    : task.status == 'IN_PROGRESS'
                                    ? Colors.orange
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.status == 'COMPLETED'
                                    ? 'Done'
                                    : task.status == 'IN_PROGRESS'
                                    ? 'In Progress'
                                    : 'Pending',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description),
                            if (task.category != null)
                              Text('Category: ${task.category}', style: TextStyle(fontWeight: FontWeight.w600)),
                            if (task.tags.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: task.tags.map((tag) => Chip(label: Text(tag))).toList(),
                              ),
                          ],
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(task: task),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                              futureTasks = TaskService().fetchTasks();
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.pushNamed(context, '/add-task');
          if (added == true) {
            setState(() {
              futureTasks = TaskService().fetchTasks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
