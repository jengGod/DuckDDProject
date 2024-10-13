import 'package:duckddproject/pages/DriverOrderPage.dart';
import 'package:duckddproject/pages/DriverProfile.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';

// Define a Package model class
class Package {
  final String location;
  final String description;
  final String destination;

  Package({
    required this.location, 
    required this.description, 
    required this.destination
  });
}

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int selectedIndex = 0;

  // List of packages
  final List<Package> packages = [
    Package(description: "description", location: "location 1", destination: "destination 1"),
    Package(description: "description", location: "location 2", destination: "destination 2"),
    Package(description: "description", location: "location 3", destination: "destination 3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 252, 227, 3), // Yellow background
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
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
            if (index == 2) {
              _showLogoutDialog(context);  // Handle logout
            } else {
              setState(() {
                selectedIndex = index;
                if (selectedIndex == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverPage()),
                  );
                } else if (selectedIndex == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverProfile()),
                  );
                }
              });
            }
          },
          type: BottomNavigationBarType.fixed, // Ensures all items are shown
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            shrinkWrap: true, // Prevent overflow error
            physics: const NeverScrollableScrollPhysics(), // Prevent scroll conflict
            itemCount: packages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  color: const Color.fromARGB(255, 221, 216, 216),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                   padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                                  child: Text(
                                    packages[index].description,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                   padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                                  child: Text(
                                    packages[index].location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 3, 3, 3),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                                  child: Text(
                                    packages[index].destination, // Changed from duplicate description
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 3, 3, 3),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          acceptOrder(context, packages[index]);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: const Text(
                                          'Accept Order',
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
                Navigator.of(context).pop(); // Close dialog
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

  void acceptOrder(BuildContext context, Package package) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Accepted order for ${package.location}')),
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Driverorderpage()),
    );
  }
}
