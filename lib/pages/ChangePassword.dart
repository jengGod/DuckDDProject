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
    String oldPassword = _oldPasswordController.text;
    String newPassword = newPasswordCtl.text;
    String confirmPassword = passCtl.text;

    // ตรวจสอบว่ามีช่องไหนที่ยังไม่ได้กรอกหรือไม่
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage(
          'กรุณากรอกข้อมูลให้ครบทุกช่อง'); // ถ้ามีช่องใดว่าง จะแสดงข้อความเตือน
      return; // หยุดการทำงานของฟังก์ชันทันที
    }

    // ตรวจสอบว่ารหัสผ่านใหม่และรหัสผ่านยืนยันตรงกันหรือไม่
    if (newPassword != confirmPassword) {
      _showMessage(
          'รหัสผ่านใหม่และการยืนยันไม่ตรงกัน'); // ถ้ารหัสผ่านไม่ตรงกัน แสดงข้อความเตือน
      return; // หยุดการทำงานของฟังก์ชันทันที
    }

    // ถ้าทุกอย่างถูกต้อง ให้ทำการอัปเดตรหัสผ่านใน Firestore และ SharedPreferences
    var db = FirebaseFirestore.instance;
    String hashedPassword = sha256
        .convert(utf8.encode(newPassword))
        .toString(); // แฮชรหัสผ่านใหม่ด้วย SHA-256
    var data = {
      'password': hashedPassword
    }; // เตรียมข้อมูลรหัสผ่านใหม่สำหรับอัปเดต

    try {
      await db.collection('Users').doc(phonenumber).update(
          data); // อัปเดตรหัสผ่านใน Firestore โดยใช้หมายเลขโทรศัพท์เป็น Document ID

      // บันทึกรหัสผ่านใหม่ลงใน SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('password', newPassword);

      _showMessage(
          'เปลี่ยนรหัสผ่านสำเร็จ'); // แสดงข้อความว่าการเปลี่ยนรหัสผ่านสำเร็จ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const userProfile()),
      );
    
  } catch (e) {
    _showMessage('เกิดข้อผิดพลาดในการอัปเดตรหัสผ่าน กรุณาลองอีกครั้ง'); // ถ้ามีข้อผิดพลาดในการอัปเดต จะแสดงข้อความแจ้งผู้ใช้
  }
  
}


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
