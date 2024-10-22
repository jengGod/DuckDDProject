// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:core';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:duckddproject/pages/DriverHomePage.dart';
import 'package:duckddproject/pages/RegisterDriver.dart';
import 'package:duckddproject/pages/RegisterUser.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passCtl = TextEditingController();
  bool isLoggingIn = false;
  late final String password;
  
  @override
  Widget build(BuildContext contxte) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: DiagonalPainter(),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'DUCK DRIVER DELIVERY',
                    style: TextStyle(
                      fontFamily: 'Lobster',
                      fontSize: 26,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const Text(
                    '"Quick, Reliable, Duck Driver Style!"',
                    style: TextStyle(
                      fontFamily: 'Lobster',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 80),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 500,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 100),
                                const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontFamily: 'Lobster',
                                    fontSize: 38,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                                Image.asset(
                                  'assets/image/logoduck.png',
                                  width: 100,
                                  height: 65,
                                ),
                              ],
                            ),
                            const Text(
                              'PLEASE SIGN IN TO CONTINUE',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Lobster',
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: phoneCtl,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      labelText: 'Phone number',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Color(0xFFF0ECF6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 16.0),
                                    ),
                                    obscureText: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(RegExp(
                                          r'\s')), // ป้องกันการป้อน Space
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: passCtl,
                                    decoration: const InputDecoration(
                                      filled: true,
                                      labelText: 'Password',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      fillColor: Color(0xFFF0ECF6),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 16.0),
                                    ),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: isLoggingIn
                                            ? null
                                            : () => login(
                                                context), // ป้องกันการกดปุ่มซ้ำ
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
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
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Don't have an account? "),
                                      TextButton(
                                        onPressed: () => register(context),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.transparent,
                                          padding: EdgeInsets
                                              .zero, // Background color transparent
                                        ),
                                        child: const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            color: Colors
                                                .blue, // Text color remains blue
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Or join us as Duck driver "),
                                      TextButton(
                                        onPressed: () =>
                                            registerDriver(context),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.transparent,
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Text(
                                          'Sign up as driver',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> login(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String hashedPassword =
        sha256.convert(utf8.encode(passCtl.text)).toString();
    try {
      // ตรวจสอบข้อมูลใน Firestore
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DocumentSnapshot userDoc = await firestore.collection('Users').doc(phoneCtl.text).get();
      DocumentSnapshot driverDoc = await firestore.collection('Drivers').doc(phoneCtl.text).get();

      if (userDoc.exists) {
        // ตรวจสอบรหัสผ่าน
        if (userDoc['password'] == hashedPassword) {
          var userData = userDoc.data() as Map<String, dynamic>;
          await prefs.setString('username', userData['username']);
          await prefs.setString('email', userData['email']);
          await prefs.setString('phonenumber', userData['phonenumber']);
          await prefs.setString('profile_picture', userData['profile_picture']);
          await prefs.setString('password', passCtl.text); 
          log('Login successful!');
         
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserHomePage()),
           
          );
        } else {
          log('Incorrect password.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      }else if(driverDoc.exists){
        if (driverDoc['password'] == hashedPassword) {
          var driverData = driverDoc .data() as Map<String, dynamic>;
          await prefs.setString('username', driverData['username']);
          await prefs.setString('email', driverData['email']);
          await prefs.setString('phonenumber', driverData['phonenumber']);
          await prefs.setString('profile_picture', driverData['profile_picture']);
          log('Login successful!');
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverPage()),//--------------------**
          );
        } else {
          log('Incorrect password.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        log('No user found with that Phonenumber.');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found with that Phonenumber.')),
        );
      }
    } catch (e) {
      log('Error: $e');
    }
  }
}

void register(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Registeruser()),
  );
}

void registerDriver(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Registerdriver()),
  );
}

// Custom Painter for diagonal background
class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    // Top-left background (white)
    paint.color = Color(0xFFF5F0FF);
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.4); // Adjust the diagonal line (30% height)
    path.lineTo(size.width,
        size.height * 0.2); // Set diagonal slant just below the tagline
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    // Bottom-right background (yellow)
    paint.color = Colors.yellow;
    path = Path();
    path.moveTo(
        0, size.height * 0.4); // Start from the bottom of the white background
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(
        size.width, size.height * 0.2); // End the yellow diagonal at 20% height
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
