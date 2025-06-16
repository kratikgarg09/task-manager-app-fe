import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task.dart';
import 'api_helper.dart';

class TaskService {
  Future<List<Task>> fetchTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    final baseUrl = ApiHelper.getBaseUrl();

    final response = await http.get(
      Uri.parse('$baseUrl/tasks/get-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
