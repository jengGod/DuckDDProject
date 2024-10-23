import 'dart:async';
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
  final Map<String, dynamic> order;

  const Statusorder({Key? key, required this.order}) : super(key: key);

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

  LatLng? latLng;
  LatLng? latLngSend;
  LatLng? latLngReceiver;
  Timer? locationUpdateTimer;
  Timer? locationTimer;

  bool _isUpdatingLocation = false;
  @override
  void initState() {
    super.initState();
    driverLocation();
    startLocationUpdates();
  }
  
  Future<void> driverLocation() async{
    if (widget.order['rider'].toString == null) return;
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('Driver_location')
          .doc(widget.order['rider'].toString())
          .get();
      var data = documentSnapshot.data();
       if (data != null){
        double lati = data?['location_loti'];
        double long = data?['location_long'];
         setState(() {
        latLng = LatLng(lati, long);
        log('Driver Location: lati: $lati, long: $long');
        });
       }else {
        log('No latitude or longitude found in Firestore document');
      }
      if (latLng != null) {
        mapController.move(latLng!, 17.0);
      }
    } catch (e) {
      log('Error updating location: $e');
    }
  }

  void startLocationUpdates() {
    // Start updating only if not already updating
    if (!_isUpdatingLocation) {
      _isUpdatingLocation = true;

      // Start a Timer that updates the location every 5 seconds (for example)
      locationTimer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
        driverLocation();
      });
    }
  }
   @override
  void dispose() {
    // Stop location updates when the widget is disposed
    stopLocationUpdates();
    super.dispose();
  }

  void stopLocationUpdates() {
    // Cancel the Timer to stop location updates
    if (locationTimer != null) {
      locationTimer!.cancel();
      locationTimer = null;
    }
    _isUpdatingLocation = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('เลือกตำแหน่งบนแผนที่'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            stopLocationUpdates();
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
  latLngSend = LatLng(
      widget.order['s_location_lat'],
      widget.order['s_location_lng'],
    );
    latLngReceiver = LatLng(
      widget.order['r_location_lat'],
      widget.order['r_location_lng'],
    );
  return SizedBox(
      width: 400,
      height: 800,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: latLng!,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            maxNativeZoom: 19,
          ),
          MarkerLayer(
            markers: [
              // Marker for the rider's current location
              if (latLng != null)
                Marker(
                  point: latLng!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.motorcycle,
                    color: Colors.yellow,
                    size: 40,
                  ),
                ),
              // Marker for the sender's location
              if (latLngSend != null)
                Marker(
                  point: latLngSend!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              // Marker for the receiver's location
              if (latLngReceiver != null)
                Marker(
                  point: latLngReceiver!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.flag,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
            ],
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
}