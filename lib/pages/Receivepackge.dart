import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'UserHome.dart';
import 'packagelist.dart';
import 'profile.dart';

class Receciveuser extends StatefulWidget {
  const Receciveuser({super.key});

  @override
  State<Receciveuser> createState() => _RececiveuserState();
}

class _RececiveuserState extends State<Receciveuser> {
  int selectedIndex = 0;

  // Dummy package data
  final List<Map<String, String>> packages = [
    {"name": "PACKAGE NAME", "description": "description"},
    {"name": "PACKAGE NAME", "description": "description"},
    {"name": "PACKAGE NAME", "description": "description"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 252, 227, 3), // Yellow background
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.black, // Selected item color
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: packages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4,
                child: Row(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: const Color.fromARGB(255, 252, 227, 3), 
                        width: 120,
                        height: 120,
                        child: const Icon(Icons.image, size: 50), 
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                packages[index]['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                packages[index]['description']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                      ),
                                      child: const Text(
                                        'more',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
}
