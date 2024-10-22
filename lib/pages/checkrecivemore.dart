import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';

class Checkmore extends StatefulWidget {
  final Map<String, dynamic> order;
  const Checkmore({super.key, required this.order});

  @override
  State<Checkmore> createState() => _CheckmoreState();
}

class _CheckmoreState extends State<Checkmore> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> order = widget.order;
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
      ),
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
              label: 'List',
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
              _onBottomNavTapped(index);
            }
          },
          type: BottomNavigationBarType.fixed, // Ensures all items are shown
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Color.fromARGB(255, 255, 254, 254),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Color.fromARGB(255, 202, 202, 202),
                  ),
                  child: order['pic_1'] != null
                      ? Image.network(
                          order['pic_1'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.black45),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'No Image Available',
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                ),
              ),
              Card(
                color: Color.fromARGB(255, 198, 195, 195),
                
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      const SizedBox(height: 16),
                      _buildInfoRow('PACKAGE NAME', order['name']),
                      const SizedBox(height: 16),
                      _buildInfoRow('PACKAGE DESCRIPTION', order['descrip']),
                      const SizedBox(height: 16),
                      _buildInfoRow('SENDER NAME', order['s_name']),
                      const SizedBox(height: 16),
                      _buildInfoRow('SENDER PHONE NUMBER', order['sender']),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'PACKAGE STATUS',
                        order['order_status'] == '1'
                            ? 'Search for driver'
                            : order['order_status'] == '2'
                                ? 'Pickup package'
                                : order['order_status'] == '3'
                                    ? 'Delivering'
                                    : order['order_status'] == '4'
                                        ? 'Delivered'
                                        : 'unknown',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => checkstatus(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Check package status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'Not available',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      selectedIndex = index;
      switch (selectedIndex) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Packagelist()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const userProfile()),
          );
          break;
      }
    });
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

  void checkstatus(BuildContext context) {
    // Add status-checking logic here, if any.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Packagelist()),
    );
  }
}
