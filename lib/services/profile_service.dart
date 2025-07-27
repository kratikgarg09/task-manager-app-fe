import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';

class ProfileService {
  static const baseUrl = 'http://localhost:8080/api/user';

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final json = jsonDecode(response.body);
    return UserProfile.fromJson(json);
  }

  static Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    await http.put(
      Uri.parse('$baseUrl/update/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profile.toJson()),
    );
  }

  static Future<void> changePassword(String current, String newPass) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    await http.put(
      Uri.parse('$baseUrl/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'currentPassword': current, 'newPassword': newPass}),
    );
  }
}
