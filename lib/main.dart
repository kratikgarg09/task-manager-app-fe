import 'package:flutter/material.dart';
import 'package:task_manager_app_fe/screens/home/home_screen.dart';
import 'package:task_manager_app_fe/screens/tasks/add_task_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Task App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const HomeScreen(),
        '/add-task': (context) => const AddTaskScreen(),
      },
    );
  }
}
