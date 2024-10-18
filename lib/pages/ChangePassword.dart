import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Changepassword extends StatefulWidget {
  final String? password;
  const Changepassword({super.key,this.password,});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
   String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  String? password;

   final TextEditingController _oldPasswordController = TextEditingController();
   TextEditingController newPasswordCtl = TextEditingController();
   TextEditingController PassCtl = TextEditingController();
   
  // Visibility state for password fields
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChangePassword'),
      ),
      body: Center(
        child: Column(
          children: [
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _oldPasswordController,
                  obscureText: !_isOldPasswordVisible, // ปรับการซ่อนข้อความ
                  decoration: InputDecoration(
                    labelText: 'Old Pass',
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
                              !_isOldPasswordVisible; // เปลี่ยนสถานะการมองเห็น
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    // ป้องกันการลบรหัสผ่านเก่า
                    if (value.isEmpty || value != widget.password) {
                      // คืนค่าช่องกรอกเป็นรหัสผ่านเก่า
                      _oldPasswordController.text = widget.password ?? '';
                      // ย้ายเคอร์เซอร์ไปที่ท้ายข้อความ
                      _oldPasswordController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: _oldPasswordController.text.length));
                    }
                  },
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
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
                ],
                  decoration: InputDecoration(
                    labelText: 'New Pass',
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
                  controller: PassCtl,
                  obscureText: true,
                  inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
                ],
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Pass',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
          ],
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
    String? oldPassword = prefs.getString('password'); // Load old password

    // Set the old password in the controller
    _oldPasswordController.text = oldPassword ?? ''; // Update the old password field

    // Update the text field controllers with loaded data
    
  });
}
}