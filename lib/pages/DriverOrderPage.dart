import 'package:duckddproject/pages/DriverHomePage.dart';
import 'package:duckddproject/pages/DriverProfile.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:flutter/material.dart';

class DriverOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const DriverOrderPage({super.key, required this.order});

  @override
  State<DriverOrderPage> createState() => _DriverOrderPageState();
}

class _DriverOrderPageState extends State<DriverOrderPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล order จาก widget.order
    Map<String, dynamic> order = widget.order;

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Card(
                color: const Color.fromARGB(255, 221, 216, 216),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Column(
                      children: [
                        // แสดงรูปภาพจาก order['pic_1']
                        Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.yellow,
                          child: order['pic_1'] != null
                              ? Image.network(order['pic_1'], fit: BoxFit.cover)
                              : const Center(
                                  child: Text(
                                    'PACKAGE IMAGE',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // แสดงข้อมูล sender และ receiver จาก order
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Sender details
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Sender name'),
                                  Text('${order['s_name'] ?? 'Unknown'}',
                                      overflow: TextOverflow.ellipsis),
                                  Text('Sender phonenumber'),
                                  Text('${order['sender'] ?? 'Unknown'}',
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            // Receiver details
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Receiver name'),
                                  Text('${order['r_name'] ?? 'Unknown'}',
                                      overflow: TextOverflow.ellipsis),
                                  Text('Receiver phonenumber'),
                                  Text('${order['receiver'] ?? 'Unknown'}',
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                
                        
                        // Delivered camera button
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              const Text(
                                'DELIVERED',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[300],
                                ),
                                child: const Icon(Icons.camera_alt, size: 50),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  completeOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text(
                  'Order complete',
                  style: TextStyle(fontSize: 18),
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
  
  void completeOrder() {
    //delete order
  }
}
