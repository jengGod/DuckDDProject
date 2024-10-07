// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:duckddproject/pages/RegisterDriver.dart';
import 'package:duckddproject/pages/RegisterUser.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController passCtl = TextEditingController();

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
                              Image.network(
                                'https://s3-alpha-sig.figma.com/img/064a/5671/00d6873be4cfaff05137012a09f47e5b?Expires=1728864000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=JIqhPBJ6MNG-KtpO~z6EEKjjfguHVd9Jvj27YRgj5gvCNfdWuk0ODKaDNnOb1FNlNfjtBq739R2C3AIcE3tiME8j87uURXX~qwUmh-nycc51CltZoWsT4ghb6HMM5Hk81-bI2nH34QE0t6zeFRXpRyYKbfiGxO-zFXHfvXOX-IHZTdNiog7oJM0QQ3UVL5gHs9Gr6tkQN00LmC0majlu1qLvRuPm-pon0oqpar3LhmmIbqyK39N~NYpoZ5N9XIG3CEd2ab1wdYvVHmK8Cv1JtE4uqd0~0VFt-eOWabTxdxfFrCMLPKWN~JuKym-4S6g~~nnGKWvw3Ttq3Axx2K4qZA__',
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
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: Colors.black),
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
                                const SizedBox(height: 10),
                               TextField(
                                  controller: passCtl,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: Colors.black),
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
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
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
                                
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account? "),
                                    TextButton(
                                      onPressed: () {
                                        // Navigate to sign up
                                      },
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
                                      onPressed: () {
                                        
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.transparent,
                                        padding: EdgeInsets
                                            .zero, 
                                      ),
                                      child: const Text(
                                        'Sign up as driver',
                                        style: TextStyle(
                                          color: Colors
                                              .blue, 
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

  void login(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserHomePage()),
    );
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
