import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Changepassword extends StatefulWidget {
  final String? password;

  const Changepassword({super.key, this.password});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  String? documentId;
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  String? password;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController newPasswordCtl = TextEditingController();
  final TextEditingController passCtl = TextEditingController();

  // Visibility state for password fields
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadUserData(); // Load user data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const userProfile()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _oldPasswordController,
                  obscureText:
                      !_isOldPasswordVisible, // Toggle password visibility
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isOldPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isOldPasswordVisible =
                              !_isOldPasswordVisible; // Toggle visibility state
                        });
                      },
                    ),
                  ),
                  readOnly: true, // ป้องกันไม่ให้พิมพ์หรือลบข้อความ
                ),
              ),

              const SizedBox(height: 16),

              // New password field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: newPasswordCtl,
                  obscureText: !_isNewPasswordVisible,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(r'\s')), // Prevent space input
                  ],
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm New password field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: passCtl,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                        RegExp(r'\s')), // Prevent space input
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: changePassword,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
      profilePicture = prefs.getString('profile_picture');
      String? oldPassword = prefs.getString('password'); // โหลดรหัสผ่านเก่า
      _oldPasswordController.text =
          oldPassword ?? ''; // ตั้งค่ารหัสผ่านเก่าใน TextField
    });
  }

  Future<void> changePassword() async {
    var db = FirebaseFirestore.instance;
    String oldPassword = _oldPasswordController.text;
    String newPassword = newPasswordCtl.text;
    String confirmPassword = passCtl.text;

    // ตรวจสอบว่ารหัสผ่านใหม่และการยืนยันตรงกัน
    if (newPassword != confirmPassword) {
      _showMessage('New password and confirm password do not match');
      return;
    }

    // ถ้ารหัสผ่านเก่าถูกต้อง ให้ทำการแฮชและอัปเดตรหัสผ่านใหม่
    String hashedPassword = sha256.convert(utf8.encode(newPassword)).toString();
    var data = {'password': hashedPassword};
    await db.collection('Users').doc(phonenumber).update(data);

    // บันทึกรหัสผ่านใหม่ใน SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', newPassword);
    _showMessage('Password changed successfully');

    // กลับไปยังหน้าก่อนหน้า
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
