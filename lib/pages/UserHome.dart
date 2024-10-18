import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/Receivepackge.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:duckddproject/pages/sendpackage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});
  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int selectedIndex = 0;
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 252, 227, 3), // Yellow background
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'list',
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
          selectedItemColor: const Color.fromARGB(255, 110, 112, 110), // Selected item color
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
                    MaterialPageRoute(builder: (context) => const UserHomePage()),
                  );
                } else if (selectedIndex == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Packagelist()),
                  );
                } else if (selectedIndex == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const userProfile()),
                  );
                }
              });
            }
          },
          type: BottomNavigationBarType.fixed, // Ensures all items are shown
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 120),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => send(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 123, 122, 122),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(300, 60), // ขนาดขั้นต่ำของปุ่ม
                  ),
                  child: const Text(
                    'Package',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => receive(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 123, 122, 122),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    minimumSize: const Size(300, 60), // ขนาดขั้นต่ำของปุ่ม
                  ),
                  child: const Text(
                    'Receive package',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
              const SizedBox(height: 80),
            Image.asset(
              'assets/image/duck.png',
              width: 250,
              height: 250,
            ),
          ],
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
          content:  const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void send(BuildContext context) { 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SendPage()),
    );
    }
    
  void receive(BuildContext context) {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Receciveuser()),
    );
  }
    
   Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
      profilePicture = prefs.getString('profile_picture');
    });
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ลบข้อมูลผู้ใช้ทั้งหมดใน SharedPreferences
    await prefs.clear(); 
    // เปลี่ยนหน้ากลับไปยังหน้าล็อกอิน
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
