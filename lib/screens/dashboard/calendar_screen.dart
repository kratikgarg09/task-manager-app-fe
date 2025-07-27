import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'dashboard_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Task>> tasksByDate = {};
  DateTime selectedDay = DateTime.now();
  List<Task> selectedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final allTasks = await TaskService().fetchTasks();

    final map = <DateTime, List<Task>>{};
    for (final task in allTasks) {
      final date = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      map[date] = (map[date] ?? [])..add(task);
    }

    setState(() {
      tasksByDate = map;
      selectedTasks = map[selectedDay] ?? [];
    });
  }

  void _onDaySelected(DateTime day, DateTime _) {
    setState(() {
      selectedDay = day;
      selectedTasks = tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Calendar")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
            child: const Text("Dashboard"),
          ),
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2100),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            eventLoader: (day) {
              return tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
            },
            onDaySelected: _onDaySelected,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: selectedTasks.length,
              itemBuilder: (context, index) {
                final task = selectedTasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('Due: ${task.dueDate.toLocal()}'),
                  trailing: Text(task.status.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
