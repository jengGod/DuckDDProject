import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statusorder extends StatefulWidget {
  const Statusorder({super.key});

  @override
  State<Statusorder> createState() => _StatusorderState();
}

class _StatusorderState extends State<Statusorder> {
 final MapController mapController = MapController(); // ควบคุมแผนที่
  bool isLoading = true;
  int selectedIndex = 1;
  String? username;
  String? email;
  String? phonenumber;

  List<Map<String, dynamic>> usersList = [];
  List<Map<String, dynamic>> filteredList = [];
  @override
  void initState() {
    super.initState();
    fetchOrders();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
    });
  }
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
      for (var order in filteredList) {
        log('s_location_lat: ${order['s_location_lat']}');
        log('s_location_lng: ${order['s_location_lng']}');
        log('r_location_lat: ${order['r_location_lat']}');
        log('r_location_lng: ${order['r_location_lng']}');
      }
      if (filteredList.isEmpty) {
        print('No matching orders found');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('เลือกตำแหน่งบนแผนที่'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => const Packagelist()),
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
      body:Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              showMap(),
              const SizedBox(height: 40,),
              Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0), // Rounded corners
  ),
  elevation: 5,
  margin: const EdgeInsets.all(10),
  child: Padding(
    padding: const EdgeInsets.all(15.0),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Align content to center
        children: [
          // Row for the status options
           const SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'SEARCH OF DRIVER',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
                Text(
                  'PICKUP PACKAGE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
                Text(
                  'DELIVERING',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
                Text(
                  'DELIVERED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator
          // const Padding(
          //   padding: EdgeInsets.symmetric(vertical: 10),
          //   child: LinearProgressIndicator(
          //     value: 0.75, // Adjust this value based on the current status
          //     backgroundColor: Colors.grey,
          //     valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          //   ),
          // ),
          // Row with driver details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/image/duck.png', 
                    width: 20,
                    height: 20,
                  ),
                  const Text(
                    'DRIVER',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Text(
                    'Mark', // Replace with dynamic driver name
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    'LICENSE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    'abc123', // Replace with dynamic license
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    'PHONE NUMBER',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '08123456789', // Replace with dynamic phone number
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          // Button for checking package picture
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                // Action to view package picture
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('CHECK PACKAGE PICTURE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Button color
              ),
            ),
          ),
        ],
      ),
    ),
  ),
)

            ],
          ),
        ),
      ) ,
    );
  }
  @override
Widget showMap() {
  // Ensure we have valid coordinates
  if (filteredList.isEmpty) {
    return const Center(child: Text('No data to display'));
  }

  // Set the initial position to the first order's sender location
  var firstOrder = filteredList.first;
  double sLat = double.parse(firstOrder['s_location_lat'].toString());
  double sLng = double.parse(firstOrder['s_location_lng'].toString());
  LatLng initialPosition = LatLng(sLat, sLng); // Initial map center

  // Create a list of markers from the filteredList
  List<Marker> markers = filteredList.map((order) {
    // Sender's location marker
    LatLng senderPosition = LatLng(
      double.parse(order['s_location_lat'].toString()),
      double.parse(order['s_location_lng'].toString()),
    );

    // Receiver's location marker
    LatLng receiverPosition = LatLng(
      double.parse(order['r_location_lat'].toString()),
      double.parse(order['r_location_lng'].toString()),
    );

    return Marker(
      point: receiverPosition, // Receiver's location
      width: 40,
      height: 40,
      child: const Icon(
        Icons.flag, // Green flag for receiver
        color: Colors.green,
        size: 40,
      ),
    );
  }).toList();

  // Add the sender's initial marker to the list
  markers.add(
    Marker(
      point: initialPosition, // Sender's initial position
      width: 40,
      height: 40,
      child: const Icon(
        Icons.location_on, // Red pin for sender
        color: Colors.red,
        size: 40,
      ),
    ),
  );

  // Use MediaQuery to calculate the size of the map
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final double mapHeight = MediaQuery.of(context).size.height * 0.4; // 40% of screen height
      final double mapWidth = MediaQuery.of(context).size.width * 0.9; // 90% of screen width

      return Center(
        child: SizedBox(
          width: mapWidth, // Set the dynamic width
          height: mapHeight, // Set the dynamic height
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialPosition, // Initial map center
              initialZoom: 15.0, // Initial zoom level
              onMapReady: () {
                // Move the map to the sender's location after the map is rendered
                mapController.move(initialPosition, 14.0);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: markers, // Add all the markers to the map
              ),
            ],
          ),
        ),
      );
    },
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