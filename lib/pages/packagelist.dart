import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/StatusOrder.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/allShipment.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Packagelist extends StatefulWidget {
  const Packagelist({super.key});

  @override
  State<Packagelist> createState() => _PackagelistState();
}

class _PackagelistState extends State<Packagelist> {
  int selectedIndex = 1;
  LatLng? latLng;
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  MapController mapController = MapController();
  bool isLoading = true;

  get firestore => null;
  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    _determinePosition(); // เรียกฟังก์ชันหาตำแหน่งปัจจุบัน
    fetchOrders();
    loadUserData();
  }

  // Fetch users from Firestore
  Future<void> fetchOrders() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Orders').get();

      // Loop through documents and add to the usersList
      setState(() {
        usersList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Filter list where sender matches the phone number
        filteredList = usersList.where((order) {
          return order['sender'] ==
              phonenumber; // Match the sender with the user's phone number
        }).toList();
      });

      if (filteredList.isEmpty) {
        print('No matching orders found');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
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

  // ฟังก์ชันเพื่อหาตำแหน่งปัจจุบัน
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่าบริการ GPS เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // หากไม่เปิดบริการ ให้แจ้งเตือนหรือส่งกลับค่าเริ่มต้น
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // ดึงตำแหน่งปัจจุบัน
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latLng = LatLng(position.latitude, position.longitude);
      isLoading = false;
    });
    mapController.move(latLng!, 15.0); // ขยับแผนที่ไปยังตำแหน่งปัจจุบัน
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการการจัดส่ง'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserHomePage()),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: BottomNavigationBar(
          backgroundColor:
              const Color.fromARGB(255, 252, 227, 3), // Yellow background
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
          selectedItemColor:
              const Color.fromARGB(255, 110, 112, 110), // Selected item color
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
          type: BottomNavigationBarType.fixed, // Ensures all items are shown
        ),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllshipmentPage()),
              );
            },
            child: const Text('View all shipments'), // Button text
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> ordersList = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                // Filter the list based on the user's phone number
                List<Map<String, dynamic>> filteredList =
                    ordersList.where((order) {
                  return order['sender'] ==
                      phonenumber; // Match the sender with the user's phone number
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('ยังไม่มีการจัดส่ง'));
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> order = filteredList[index];
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
                                child: Image.network(
                                  order['pic_1'] ?? '',
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text('Status',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(
                                          order['order_status'] == '1'
                                              ? 'Search for driver'
                                              : order['order_status'] == '2'
                                                  ? 'Pickup package'
                                                  : order['order_status'] == '3'
                                                      ? 'Delivering'
                                                      : order['order_status'] ==
                                                              '4'
                                                          ? 'Delivered'
                                                          : 'unknown',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(
                                          'PackageName: ${order['name'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(
                                          'Description: ${order['descrip'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(255, 3, 3, 3),
                                          )),
                                      Align(
                                        alignment: Alignment.center,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            More(context, order);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                          ),
                                          child: const Text(
                                            'More',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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

  send(BuildContext context) {}

  void More(BuildContext context, Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Statusorder(order: order),
      ),
    );
    log(order['orderId'].toString());
  }
}
