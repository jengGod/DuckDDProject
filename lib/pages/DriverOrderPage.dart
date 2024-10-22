import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/DriverHomePage.dart';
import 'package:duckddproject/pages/DriverMap.dart';
import 'package:duckddproject/pages/DriverProfile.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;
  

  const DriverOrderPage({super.key, required this.order});

  @override
  State<DriverOrderPage> createState() => _DriverOrderPageState();
}

class _DriverOrderPageState extends State<DriverOrderPage> {
  int selectedIndex = 0;
  double lati=0;
  double long=0;

  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  String? plate_number;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
      profilePicture = prefs.getString('profile_picture');
      plate_number = prefs.getString('plate_number');
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot locationDoc = await firestore
          .collection('Driver_location')
          .doc(phonenumber)
          .get();
      lati = locationDoc['location_loti'];
      long = locationDoc['location_long'];
    } catch (e) {}
  }
  
  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูล order จาก widget.order
  Map<String, dynamic> order = widget.order;

 
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: BottomNavigationBar(
          backgroundColor:
              const Color.fromARGB(255, 252, 227, 3), // Yellow background
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
          selectedItemColor:
              const Color.fromARGB(255, 110, 112, 110), // Selected item color
          unselectedItemColor: Colors.black, // Unselected item color
          onTap: (int index) {
            if (index == 2) {
              _showLogoutDialog(context); // Handle logout
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
                    MaterialPageRoute(
                        builder: (context) => const DriverProfile()),
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
                                  Text('Sender address'),
                                  Text('${order['s_address'] ?? 'Unknown'}',
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
                                  Text('Receiver address'),
                                  Text('${order['r_address'] ?? 'Unknown'}',
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
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
                                width: 60,
                                height: 60,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160, // กำหนดขนาดให้ทั้งสองปุ่มเท่ากัน
                    child: ElevatedButton(
                      onPressed: () {
                        completeOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Background color
                        padding: const EdgeInsets.symmetric(
                            vertical: 16), // แค่ padding แนวตั้ง
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Order complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // เว้นระยะห่างระหว่างปุ่มทั้งสอง
                  SizedBox(
                    width: 160, // ขนาดเท่ากันกับปุ่มแรก
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Drivermap(order:order),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16), // แค่ padding แนวตั้ง
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'View map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
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
                Navigator.push(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to complete this order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DriverPage()),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<Position> realTimePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  
}
