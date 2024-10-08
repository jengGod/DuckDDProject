import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // สำหรับการกรอง input
import 'package:image_picker/image_picker.dart';// สำหรับการเลือกรูปภาพ

class Registerdriver extends StatefulWidget {
  const Registerdriver({super.key});

  @override
  State<Registerdriver> createState() => _RegisterdriverState();
}

TextEditingController usernameCtl = TextEditingController();
TextEditingController passCtl = TextEditingController();
TextEditingController emailCtl = TextEditingController();
TextEditingController walletCtl = TextEditingController();
TextEditingController passwordCtl = TextEditingController();
TextEditingController phoneCtl = TextEditingController();
TextEditingController licenseCtl = TextEditingController();
bool _isButtonPressed = false;
XFile? image; // สำหรับการจัดการรูปภาพที่เลือก

class _RegisterdriverState extends State<Registerdriver> {
  final ImagePicker picker = ImagePicker();

  // ตรวจสอบว่าฟิลด์ทั้งหมดถูกกรอกและไม่มีช่องว่าง
  bool _isFormComplete() {
    return usernameCtl.text.isNotEmpty &&
        emailCtl.text.isNotEmpty &&
        phoneCtl.text.isNotEmpty &&
        licenseCtl.text.isNotEmpty &&
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
    licenseCtl.addListener(() => setState(() {}));
    passwordCtl.addListener(() => setState(() {}));
    passCtl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Driver'),
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
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
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
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
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
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
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
                controller: licenseCtl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'License Plate Number',
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
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
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
                      RegExp(r'\s')), // ห้ามพิมพ์ spacebar
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
              const SizedBox(height: 20),
              // ส่วนเลือกอัปโหลดรูปภาพ
              FilledButton(
                  onPressed: () async {
                    log('start:');
                    final ImagePicker picker = ImagePicker();
                    image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      log('image:');
                      log(image!.path);
                      setState(() {});
                    }
                  },
                  child: const Text('Profile picture')),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: !_isFormComplete() || _isButtonPressed
                    ? null
                    : () async {
                        if (passwordCtl.text != passCtl.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Passwords do not match')),
                          );
                          return;
                        }

                        setState(() {
                          _isButtonPressed = true;
                        });

                        register(context);

                        setState(() {
                          _isButtonPressed = false;
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

  void register(BuildContext context) {
    log('Driver registered');

    var db = FirebaseFirestore.instance;
    var data = {
      'username': usernameCtl.text,
      'email': emailCtl.text,
      'phonenumber': phoneCtl.text,
      'license': licenseCtl.text,
      'password': passwordCtl.text,
      'profile_picture': image
    };

    db.collection('Driver').doc(usernameCtl.text).set(data).then((_) {
      Navigator.push(
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
