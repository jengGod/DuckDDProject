import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

class Registeruser extends StatefulWidget {
  const Registeruser({super.key});

  @override
  State<Registeruser> createState() => _RegisteruserState();
}

TextEditingController usernameCtl = TextEditingController();
TextEditingController passCtl = TextEditingController();
TextEditingController emailCtl = TextEditingController();
TextEditingController walletCtl = TextEditingController();
TextEditingController passwordCtl = TextEditingController();
TextEditingController phoneCtl = TextEditingController();

bool _isButtonPressed = false;
XFile? image;
final ImagePicker picker = ImagePicker();
String imageUrl = '';

class _RegisteruserState extends State<Registeruser> {
  // ตรวจสอบว่าข้อมูลกรอกครบทุกช่องหรือยัง
  bool _isFormComplete() {
    return usernameCtl.text.isNotEmpty &&
        emailCtl.text.isNotEmpty &&
        phoneCtl.text.isNotEmpty &&
        passwordCtl.text.isNotEmpty &&
        passCtl.text.isNotEmpty &&
        image != null;
  }

  @override
  void initState() {
    super.initState();

    // ตรวจสอบการเปลี่ยนแปลงของแต่ละ TextField เมื่อมีการกรอกข้อมูล
    usernameCtl.addListener(() => setState(() {}));
    emailCtl.addListener(() => setState(() {}));
    phoneCtl.addListener(() => setState(() {}));
    passwordCtl.addListener(() => setState(() {}));
    passCtl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: usernameCtl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Color(0xFFF0ECF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailCtl,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color(0xFFF0ECF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneCtl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  filled: true,
                  fillColor: Color(0xFFF0ECF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordCtl,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Color(0xFFF0ECF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passCtl,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Color(0xFFF0ECF6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                  onPressed: () async {
                    log('start:');
                    final ImagePicker picker = ImagePicker();
                    image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      log('image:');
                      log(image!.path);
                      imageUrl = await uploadImage(image!);
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Profile picture',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  )),
              const SizedBox(height: 30),
              ElevatedButton(
                // ปุ่มจะทำงานเฉพาะเมื่อข้อมูลครบและปุ่มยังไม่ถูกกด
                onPressed: !_isFormComplete() || _isButtonPressed
                    ? null // ปุ่มถูกปิดหากยังกรอกข้อมูลไม่ครบหรือปุ่มถูกกดแล้ว
                    : () async {
                        setState(() {
                          _isButtonPressed = true; // เปลี่ยนสถานะเป็นกดแล้ว
                        });

                        register(context); //

                        setState(() {
                          _isButtonPressed =
                              false; // เปลี่ยนสถานะกลับเมื่อเสร็จสิ้น
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

  void register(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (passwordCtl.text != passCtl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(phoneCtl.text).get();
    DocumentSnapshot driverDoc =
        await firestore.collection('Drivers').doc(phoneCtl.text).get();

    if (userDoc.exists || driverDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Phone number already exists. Please use another Phone number.')),
      );
      return; // หยุดการสมัครสมาชิก
    }
    String hashedPassword =
        sha256.convert(utf8.encode(passwordCtl.text)).toString();
    var db = FirebaseFirestore.instance;
    var data = {
      'username': usernameCtl.text,
      'email': emailCtl.text,
      'phonenumber': phoneCtl.text,
      'password': hashedPassword,
      'profile_picture': imageUrl
    };

    db.collection('Users').doc(phoneCtl.text).set(data).then((_) {
      Navigator.pop(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
}
