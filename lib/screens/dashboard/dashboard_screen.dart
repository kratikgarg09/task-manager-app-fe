import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/dashboard_service.dart';
import '../../services/task_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> dashboardData;
  late Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    dashboardData = DashboardService.fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Summary")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCard("Total", data['total'], Colors.blue),
                _buildCard("Completed", data['completed'], Colors.green),
                _buildCard("Pending", data['pending'], Colors.orange),
                _buildCard("Overdue", data['overdue'], Colors.red),
                _buildCard("Due Today", data['dueToday'], Colors.purple),
              ],
            ),
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

  Widget _buildCard(String title, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 2,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
