import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/ChangePasswordDriver.dart';
import 'package:duckddproject/pages/DriverHomePage.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/RegisterDriver.dart';
import 'package:duckddproject/pages/RegisterUser.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({super.key});

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  String? plate_number;
  XFile? image;
  final ImagePicker picker = ImagePicker();
  String imageUrl = '';

  TextEditingController usernameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController phonenumbeCtl = TextEditingController();
  TextEditingController plate_numberCtl = TextEditingController();

  int selectedIndex = 1;

  bool _isFormComplete() {
    return emailCtl.text.isNotEmpty &&
        usernameCtl.text.isNotEmpty &&
        phonenumbeCtl.text.isNotEmpty &&
        plate_numberCtl.text.isEmpty;
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
      profilePicture = prefs.getString('profile_picture');
      plate_number = prefs.getString('plate_number');

      usernameCtl.text = username ?? '';
      // Update the text field controllers with loaded data
      emailCtl.text = email ?? '';
      plate_numberCtl.text = plate_number ?? '';
      phonenumbeCtl.text = phonenumber ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    // _oldPasswordController.text =
    //
    //   widget.password ?? ''; // Set the old password field
    usernameCtl.addListener(() => setState(() {}));
    emailCtl.addListener(() => setState(() {}));
    phonenumbeCtl.addListener(() => setState(() {}));

    plate_numberCtl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: BottomNavigationBar(
          backgroundColor:
              const Color.fromARGB(255, 252, 227, 3), // Yellow background
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
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
            if (index == 2) {
              _showLogoutDialog(context); // Handle logout
            } else {
              setState(() {
                selectedIndex = index;
                if (selectedIndex == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverPage()),
                  );
                } else if (selectedIndex == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DriverProfile()),
                  );
                }
              });
            }
          },
          type: BottomNavigationBarType.fixed, // Ensures all items are shown
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            height: 140, // Set a fixed height for the profile image section
            alignment: Alignment.center,
            child: Stack(
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
                    }),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // Scrollable profile form fields
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phonenumbeCtl,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: plate_numberCtl,
                      decoration: const InputDecoration(
                        labelText: 'Plate Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Changepass(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 155, 155, 153),
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
                    // Save Changes Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => saveChanges(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logout dialog
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
                Navigator.of(context).pop(); // Close dialog
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

  Future<void> saveChanges(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String oldPhonenumber = prefs.getString('phonenumber') ?? '';

    // อัปเดตข้อมูลใน SharedPreferences
    await prefs.setString('email', emailCtl.text);
    await prefs.setString('username', usernameCtl.text);
    await prefs.setString('phonenumber', phonenumbeCtl.text);
    await prefs.setString('plate_number', plate_numberCtl.text);

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

  Future<void> updateUserDataInFirestore(String updatedImageUrl) async {
    var db = FirebaseFirestore.instance;

    // ค้นหาผู้ใช้ตามเบอร์โทรเก่าเพื่อดึง documentId
    QuerySnapshot querySnapshot = await db
        .collection('Drivers')
        .where('phonenumber', isEqualTo: phonenumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // ถ้ามีผู้ใช้ให้ทำการอัปเดต
      String documentId = querySnapshot.docs.first.id;

      var data = {
        'username': usernameCtl.text,
        'email': emailCtl.text,
        'phonenumber': phonenumbeCtl.text,
        'license': plate_numberCtl.text,
        'profile_picture': updatedImageUrl,
      };

      // อัปเดตข้อมูลใน document เดิม
      await db.collection('Drivers').doc(documentId).update(data);

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

  Changepass(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Changepassworddriver()),
    );
  }
}
