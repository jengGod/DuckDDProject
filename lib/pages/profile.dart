import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userProfile extends StatefulWidget {
  final String? email;
  final String? username;
  final String? phonenumber;
  final String? profilePicture;
  final String? password;

  const userProfile({
    super.key,
    this.email,
    this.username,
    this.phonenumber,
    this.profilePicture,
    this.password,
  });

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  int selectedIndex = 2;
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  bool _isButtonPressed = false;
  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
   TextEditingController newPasswordCtl = TextEditingController();
   TextEditingController PassCtl = TextEditingController();
  final TextEditingController phoneCtl = TextEditingController();

  // Visibility state for password fields
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

 bool _isFormComplete() {
    return 
        newPasswordCtl.text.isNotEmpty &&
        PassCtl.text.isNotEmpty ;
       
  }

XFile? image;
final ImagePicker picker = ImagePicker();
String imageUrl = '';
  @override
  void initState() {
    super.initState();
    loadUserData();
    // _oldPasswordController.text =
    //  
    //   widget.password ?? ''; // Set the old password field
    _usernameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    phoneCtl.addListener(() => setState(() {}));
    _oldPasswordController.addListener(() => setState(() {}));
    newPasswordCtl.addListener(() => setState(() {}));
    PassCtl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: BottomNavigationBar(
          backgroundColor:
              const Color.fromARGB(255, 252, 227, 3), // Yellow background
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor:
              const Color.fromARGB(255, 110, 112, 110), // Selected item color
          unselectedItemColor: Colors.black, // Unselected item color
          onTap: (int index) {
            if (index == 3) {
              _showLogoutDialog(context);
            } else {
              setState(() {
                selectedIndex = index;
                if (selectedIndex == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserHomePage()),
                  );
                } else if (selectedIndex == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Packagelist()),
                  );
                } else if (selectedIndex == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const userProfile()),
                  );
                }
              });
            }
          },
          type: BottomNavigationBarType.fixed, // Ensures all items are shown
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePicture != null
                        ? NetworkImage(profilePicture!)
                        : const AssetImage('asset/logoduck.png'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                   onPressed: () async {
                    log('start:');
                    final ImagePicker picker = ImagePicker();
                    image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      log('image:');
                      log(image!.path);
                      imageUrl = await uploadImage(image!);
                      setState(() {});
                    }}
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Email field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Phone number field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _phonenumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Changelocation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Change location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !_isFormComplete() || _isButtonPressed
                    ? null // ปุ่มถูกปิดหากยังกรอกข้อมูลไม่ครบหรือปุ่มถูกกดแล้ว
                    : () async {
                        setState(() {
                          _isButtonPressed = true; // เปลี่ยนสถานะเป็นกดแล้ว
                        });

                        Savelocation(context); //

                        setState(() {
                          _isButtonPressed =
                              false; // เปลี่ยนสถานะกลับเมื่อเสร็จสิ้น
                        });
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Save location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
  Future<String> uploadImage(XFile image) async {
    // สร้าง Reference สำหรับ Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();

    // สร้าง path สำหรับเก็บรูปภาพ
    final imageRef = storageRef.child('profile_pictures/${image.name}');

    // อัปโหลดรูปภาพ
    await imageRef.putFile(File(image.path));

    // รับ URL ของรูปภาพที่ถูกอัปโหลด
    String downloadURL = await imageRef.getDownloadURL();
    return downloadURL;
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
    _emailController.text = email ?? '';
    _usernameController.text = username ?? '';
    _phonenumberController.text = phonenumber ?? '';
  });
}




  Future<void> Savelocation(BuildContext context) async {
  if (newPasswordCtl.text != PassCtl.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Passwords do not match')),
    );
    return;
  }
  
  String hashedPassword = sha256.convert(utf8.encode(newPasswordCtl.text)).toString();

  // บันทึกข้อมูลผู้ใช้ที่อัปเดตใน SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', _emailController.text);
  await prefs.setString('username', _usernameController.text);
  await prefs.setString('phonenumber', _phonenumberController.text);
  await prefs.setString('password', newPasswordCtl.text);

  if (imageUrl.isNotEmpty) {
    await prefs.setString('profile_picture', imageUrl);
  }

  // เรียกใช้ฟังก์ชันเพื่ออัปเดตข้อมูลผู้ใช้ใน Firestore
  await updateUserDataInFirestore(prefs.getString('email')!);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Profile updated successfully')),
  );
}

// ฟังก์ชันสำหรับอัปเดตข้อมูลผู้ใช้ใน Firestore
Future<void> updateUserDataInFirestore(String email) async {
  
  String hashedPassword = sha256.convert(utf8.encode(newPasswordCtl.text)).toString();
  var db = FirebaseFirestore.instance;

  // ค้นหาผู้ใช้ตามอีเมลเพื่อดึง documentId
  QuerySnapshot querySnapshot = await db.collection('users').where('email', isEqualTo: email).get();
  
  if (querySnapshot.docs.isNotEmpty) {
    String documentId = querySnapshot.docs.first.id; // ดึง documentId ของผู้ใช้

    var data = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'phonenumber': _phonenumberController.text,
      'password': hashedPassword,
      'profile_picture': imageUrl,
    };

    // อัปเดตข้อมูลใน Firestore
    await db.collection('users').doc(documentId).update(data);
  } else {
    print('User not found in Firestore.');
  }
}


  Changelocation(BuildContext context) {
   
  }
}
