import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/Receivepackge.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:duckddproject/pages/sendpackage.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Send package',
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
            Image.network(
              'https://s3-alpha-sig.figma.com/img/653f/b6ea/a590e785cdd2f0c86c5b78ee99208920?Expires=1729468800&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=KHDXbSOF88y5BXTlOy-MFgf0I9QEqtdhDNLWaqE85DAAIZS-lRETTinI0ReepRhdRE29DRJP-jTX8xFyeEPLAot-pYqhSljUhBhUWamtO2-cL88fKSTp3Mvq1jqWThF265CHQEKvOnU-pjlICBShcsomCHJFyqKyK70eFD6R6McjD9qy7ObD~~Aq3wR9sHKhOIsKYPE2YUmHIsPhmT8nnQqNUdRE88EAa7j-DiQZ4ktMQvpRfiLCecgixkhSr6jMyNEZIcJ5QzBlA53QjbOh8ML35OfPY8SynyoWKynV5NNSL8xlqWtrsbor0yArX0h1MNrII9k~z0YaiOI2cJk9pQ__',
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
          content: const Text('Do you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()), // นำทางไปยังหน้า LoginPage
                );
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
}
