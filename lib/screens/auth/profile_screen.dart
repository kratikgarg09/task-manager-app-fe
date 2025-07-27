import 'package:flutter/material.dart';
import '../../models/profile.dart';
import '../../services/profile_service.dart';
import '../dashboard/dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController mobileNumberController;
  late TextEditingController emailController;
  late TextEditingController currentPassController;
  late TextEditingController newPassController;
  late Future<UserProfile> profileFuture;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    mobileNumberController = TextEditingController();
    emailController = TextEditingController();
    currentPassController = TextEditingController();
    newPassController = TextEditingController();
    profileFuture = ProfileService.getProfile();
  }

  void _saveProfile() async {
    final profile = UserProfile(name: nameController.text, email: emailController.text, mobileNumber:
    mobileNumberController.text);
    await ProfileService.updateProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
  }

  void _changePassword() async {
    await ProfileService.changePassword(
      currentPassController.text,
      newPassController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<UserProfile>(
        future: profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final profile = snapshot.data!;
          nameController.text = profile.name;
          mobileNumberController.text = profile.mobileNumber;
          emailController.text = profile.email;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                  child: const Text("Dashboard"),
                ),
                // Text("Email: ${profile.email}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email ID"),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: mobileNumberController,
                  decoration: const InputDecoration(labelText: "Mobile Number"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text("Update Profile"),
                ),
                const Divider(height: 32),
                TextField(
                  controller: currentPassController,
                  decoration: const InputDecoration(labelText: "Current Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: newPassController,
                  decoration: const InputDecoration(labelText: "New Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text("Change Password"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
