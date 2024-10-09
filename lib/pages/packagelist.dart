import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';

class Packagelist extends StatefulWidget {
  const Packagelist({super.key});

  @override
  State<Packagelist> createState() => _PackagelistState();
}

class _PackagelistState extends State<Packagelist> {
  int selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 252, 227, 3), // ตั้งค่าสีพื้นหลังเป็นสีเหลือง
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black, // สีของไอเท็มที่ถูกเลือก
          unselectedItemColor: Colors.black, // สีของไอเท็มที่ไม่ได้ถูกเลือก
          onTap: (int index) {
            if (index == 3) { // ถ้าเป็น Logout
              _showLogoutDialog(context);
            } else {
              setState(() {
                selectedIndex = index;
                // นำทางไปยังหน้าต่าง ๆ เมื่อไอคอนถูกกด
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
        ),
      ),
      body: const Text('page'),
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
}