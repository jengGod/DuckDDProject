import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/Changelocation.dart';
import 'package:duckddproject/pages/Location.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:latlong2/latlong.dart';

class Registeruser extends StatefulWidget {
  final LatLng? selectedLocation;
  const Registeruser({super.key, this.selectedLocation});

  @override
  State<Registeruser> createState() => _RegisteruserState();
}

TextEditingController usernameCtl = TextEditingController();
TextEditingController passCtl = TextEditingController();
TextEditingController emailCtl = TextEditingController();
TextEditingController addressCtl = TextEditingController();
TextEditingController walletCtl = TextEditingController();
TextEditingController passwordCtl = TextEditingController();
TextEditingController phoneCtl = TextEditingController();

bool _isButtonPressed = false;
bool isLocationChecked = false;
XFile? image;
final ImagePicker picker = ImagePicker();
String imageUrl = '';
double lati = 0;
double long = 0;
bool ispassCtl = false;
bool ispasswordCtl = false;

class _RegisteruserState extends State<Registeruser> {
  bool isLocationSelected = false;
  final _formKey = GlobalKey<FormState>();

  // ตรวจสอบว่าข้อมูลกรอกครบทุกช่องหรือยัง
  bool _isFormComplete() {
    return usernameCtl.text.isNotEmpty &&
        emailCtl.text.isNotEmpty &&
        phoneCtl.text.isNotEmpty &&
        addressCtl.text.isNotEmpty &&
        passwordCtl.text.isNotEmpty &&
        passCtl.text.isNotEmpty &&
        image != null &&
        widget.selectedLocation != null;
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
              if (image != null)
                ClipOval(
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[300],
                    child: Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),

              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              Form(
                key: _formKey,
                child: TextFormField(
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // ตรวจสอบว่าอีเมลมีรูปแบบถูกต้องหรือไม่
                    String pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
                    RegExp regex = RegExp(pattern);
                    if (!regex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),
              TextField(
                controller: addressCtl,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: const [
                  // FilteringTextInputFormatter.deny(
                  //     RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: const InputDecoration(
                  labelText: 'address',
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
                  FilteringTextInputFormatter
                      .digitsOnly, // รับเฉพาะตัวเลขเท่านั้น
                  LengthLimitingTextInputFormatter(
                      10), // จำกัดความยาวที่ 10 หลัก
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
                obscureText: !ispasswordCtl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar
                ],
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: const Color(0xFFF0ECF6),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ispasswordCtl ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ispasswordCtl = !ispasswordCtl;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passCtl,
                obscureText: !ispassCtl,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                      RegExp(r'\s')), // ไม่ให้กรอก spacebar kub
                ],
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: const Color(0xFFF0ECF6),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ispassCtl ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        ispassCtl = !ispassCtl;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // CheckboxListTile(
              //     title: const Text('ใช้ตำแหน่งปัจจุบันเป็นที่อยู่'),
              //     value: isLocationChecked,
              //     onChanged: (bool? value) async {
              //       setState(() {
              //         isLocationChecked = value ?? false;
              //       });
              //       if (isLocationChecked) {
              //         var position = await _determinePosition();
              //         log('${position.latitude} ${position.longitude}');
              //         lati = position.latitude;
              //         long = position.longitude;
              //       }
              //     }),
              ElevatedButton(
                // ปุ่มจะทำงานเฉพาะเมื่อข้อมูลครบและปุ่มยังไม่ถูกกด
                onPressed: () {
                  GpsMap(context);
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
                  'location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 5),
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
      return; // Stop registration
    }

    String hashedPassword =
        sha256.convert(utf8.encode(passwordCtl.text)).toString();
    var db = FirebaseFirestore.instance;
    var data = {
      'username': usernameCtl.text,
      'email': emailCtl.text,
      'phonenumber': phoneCtl.text,
      'address': addressCtl.text,
      'password': hashedPassword,
      'profile_picture': imageUrl,
    };

    if (widget.selectedLocation != null) {
      // Store the selected location coordinates if available
      log('Selected Latitude: ${widget.selectedLocation!.latitude}');
      log('Selected Longitude: ${widget.selectedLocation!.longitude}');
      var location_user = {
        'location_loti': widget.selectedLocation!.latitude,
        'location_long': widget.selectedLocation!.longitude,
      };
      db.collection('Users_location').doc(phoneCtl.text).set(location_user);
    } else {
      // If no location was selected manually, use current GPS location
      var position = await _determinePosition();
      var location_user = {
        'location_loti': position.latitude,
        'location_long': position.longitude,
      };
      db.collection('Users_location').doc(phoneCtl.text).set(location_user);
    }

    db.collection('Users').doc(phoneCtl.text).set(data).then((_) {
      // Navigate to LoginPage or another page as needed
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void GpsMap(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Location()),
    );
  }
}
