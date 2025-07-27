import 'package:flutter/src/widgets/editable_text.dart';
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

  static Future<List<Task>> searchTasks({
    String? title,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String ? tags,
    String ? category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    final queryParams = {
      if (title != null && title.isNotEmpty) 'title': title,
      if (title != null && tags!.isNotEmpty) 'title': tags,
      if (title != null && category!.isNotEmpty) 'title': category,
      if (status != null) 'status': status,
      if (fromDate != null) 'fromDate': fromDate.toIso8601String().split('T').first,
      if (toDate != null) 'toDate': toDate.toIso8601String().split('T').first,
    };
    final uri = Uri.http('localhost:8080', '/api/tasks/search-task-filter', queryParams);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    final List data = jsonDecode(response.body);
    return data.map((json) => Task.fromJson(json)).toList();
  }

}
