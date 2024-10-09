import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:flutter/material.dart';

class userProfile extends StatefulWidget {
  const userProfile({super.key});

  @override
  State<userProfile> createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  int selectedIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(
              255, 252, 227, 3), // ตั้งค่าสีพื้นหลังเป็นสีเหลือง
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black, // สีของไอเท็มที่ถูกเลือก
          unselectedItemColor: Colors.black, // สีของไอเท็มที่ไม่ได้ถูกเลือก
          onTap: (int index) {
            if (index == 3) {
              // ถ้าเป็น Logout
              _showLogoutDialog(context);
            } else {
              setState(() {
                selectedIndex = index;
                // นำทางไปยังหน้าต่าง ๆ เมื่อไอคอนถูกกด
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
          
              // Email field
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              // Name field
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              // Phone number field
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              // Old password field
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Old Pass',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              // New password field
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Pass',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Pass',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity, // Make the button take up full width like the TextField
                  child: ElevatedButton(
                    onPressed: () => Changelocation(context),
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
                  width: double.infinity, // Make the button take up full width like the TextField
                  child: ElevatedButton(
                    onPressed: () => Savelocation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
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

  Savelocation(BuildContext context) {}

  Changelocation(BuildContext context) {}
}
