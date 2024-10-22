import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:duckddproject/pages/ChangePassword.dart';
import 'package:duckddproject/pages/Changelocation.dart';
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
  String? oldPassword;
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
  bool _isPhonenumber = false;
  bool _isNewPasswordVisible = false;

  bool _isFormComplete() {
    return _emailController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _phonenumberController.text.isNotEmpty;
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
                        image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          log('image:');
                          log(image!.path);
                          imageUrl = await uploadImage(image!);
                          setState(() {});
                        }
                      }
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
                    labelText: 'Phonenumber',
                    border: OutlineInputBorder(),
                    // suffixIcon: IconButton(
                    //   icon: Icon(
                    //     _isPhonenumber
                    //         ? Icons.visibility
                    //         : Icons.visibility_off,
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       _isPhonenumber =
                    //           !_isPhonenumber; // Toggle visibility state
                    //     });
                    //   },
                    // ),
                  ),
                  readOnly: true, // ป้องกันไม่ให้พิมพ์หรือลบข้อความ
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Changepass(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 155, 155, 153),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Change Password',
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
                    onPressed: () => changelocation(context),
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
                    onPressed: () => Savelocation(context) //

                    ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 77, 209, 0),
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
      oldPassword = prefs.getString('password'); // Load old password

      // Set the old password in the controller
      oldPassword = oldPassword ?? '';

      // Update the text field controllers with loaded data
      _emailController.text = email ?? '';
      _usernameController.text = username ?? '';
      _phonenumberController.text = phonenumber ?? '';
      phonenumber = phonenumber ?? '';
    });
  }

  Future<void> Savelocation(BuildContext context) async {
    if (newPasswordCtl.text != PassCtl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String oldPhonenumber = prefs.getString('phonenumber') ?? '';

    // อัปเดตข้อมูลใน SharedPreferences
    await prefs.setString('email', _emailController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('phonenumber', _phonenumberController.text);

    // ตรวจสอบว่ามีการอัปโหลดรูปภาพใหม่หรือไม่
    if (image != null) {
      String newImageUrl = await uploadImage(image!);
      log('Image uploaded URL: $newImageUrl');

      await prefs.setString('profile_picture', newImageUrl);
      setState(() {
        profilePicture = newImageUrl;
      });
    }

    // อัปเดตข้อมูลใน Firestore
    await updateUserDataInFirestore(
        profilePicture != null ? profilePicture! : '');

    // โหลดข้อมูลผู้ใช้ใหม่
    await loadUserData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> updateUserDataInFirestore(String updatedImageUrl) async {
    var db = FirebaseFirestore.instance;

    // ค้นหาผู้ใช้ตามเบอร์โทรเก่าเพื่อดึง documentId
    QuerySnapshot querySnapshot = await db
        .collection('Users')
        .where('phonenumber', isEqualTo: phonenumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // ถ้ามีผู้ใช้ให้ทำการอัปเดต
      String hashedPassword =
          sha256.convert(utf8.encode(oldPassword!)).toString();
      String documentId = querySnapshot.docs.first.id;

      var data = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'phonenumber': _phonenumberController.text, 
        'profile_picture': updatedImageUrl,
        'password': hashedPassword
      };

      // อัปเดตข้อมูลใน document เดิม
      await db.collection('Users').doc(documentId).update(data);

      // // เปลี่ยนชื่อ document ตามเบอร์โทรใหม่
      // await db.collection('Users').doc(documentId).delete(); // ลบเอกสารเก่า
      // await db
      //     .collection('Users')
      //     .doc(_phonenumberController.text)
      //     .set(data); // สร้างเอกสารใหม่
    } else {
      print('User not found in Firestore.');
    }
  }

  changelocation(BuildContext context) {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Changelocation()),
    );
  }
  
    
  Changepass(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Changepassword()),
    );
  }
}
