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
  String? profilePicture;

  LatLng? latLng;
  LatLng? latLngSend;
  LatLng? latLngReceiver;
  Timer? locationUpdateTimer;
  Timer? locationTimer;

  double lati = 0;
  double long = 0;

  bool _isUpdatingLocation = false;
  @override
  void initState() {
    super.initState();
    loadUserData();
    driverLocation();
    startLocationUpdates();
  }

  Future<void> loadUserData() async {
    if (widget.order['rider'] == null ||
        widget.order['rider'].toString().isEmpty) {
      // Assign default values when there is no rider
      username = "รอพนักงานรับงาน";
      profilePicture = null; // Or provide a default image path if you have one
      return;
    }

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot locationDoc = await firestore
          .collection('Drivers')
          .doc(widget.order['rider'].toString())
          .get();

      if (locationDoc.exists) {
        username = locationDoc['username'];
        profilePicture = locationDoc['profile_picture'];
      } else {
        // If the document doesn't exist, assign default values
        username = "รอพนักงานรับงาน";
        profilePicture = null;
      }
    } catch (e) {
      // Handle errors by setting default values
      username = "รอพนักงานรับงาน";
      profilePicture = null;
    }
  }

  Future<void> driverLocation() async {
    if (widget.order['rider'] == null ||
        widget.order['rider'].toString().isEmpty) {
      log('No rider assigned. Waiting for a driver to accept the order.');
      return;
    }

    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('Driver_location')
          .doc(widget.order['rider'].toString())
          .get();
      var data = documentSnapshot.data();

      if (data != null) {
        setState(() {
          lati = data?['location_loti'] ??
              0.0; // Provide default values if necessary
          long = data?['location_long'] ?? 0.0;
          latLng = LatLng(lati, long);
          log('Driver Location: lati: $lati, long: $long');
        });
      } else {
        log('No latitude or longitude found in Firestore document');
        // Optionally provide a default location if no data is found
        setState(() {
          lati = 0.0; // Default latitude
          long = 0.0; // Default longitude
          latLng = LatLng(lati, long);
        });
      }

      if (latLng != null) {
        mapController.move(latLng!, 18.0);
      }
    } catch (e) {
      log('Error updating location: $e');
    }
  }

  void startLocationUpdates() {
    // Check if rider exists before starting location updates
    if (widget.order['rider'] == null ||
        widget.order['rider'].toString().isEmpty) {
      log('No rider assigned. Real-time location updates are not needed.');
      return; // Don't start location updates if no rider is assigned
    }

    // Start updating only if not already updating
    if (!_isUpdatingLocation) {
      _isUpdatingLocation = true;

      // Start a Timer that updates the location every 3 seconds
      locationTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
        driverLocation();
      });
    }
  }

  @override
  void dispose() {
    stopLocationUpdates(); // Ensure location updates stop
    super.dispose();
  }

  void stopLocationUpdates() {
    if (_isUpdatingLocation && locationTimer != null) {
      locationTimer?.cancel(); // Stop the periodic timer
      _isUpdatingLocation = false; // Reset the flag
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              showMap(),
              const SizedBox(
                height: 40,
              ),
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
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Align content to center
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
                        Row(
                          children: [
                            Image.asset(
                              'assets/image/duck.png',
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (widget.order['rider'] == null ||
                            widget.order['rider'].toString().isEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'DRIVER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'รอพนักงานรับงาน', // Display a default message if null
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'LICENSE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'Unknown', // Fallback to 'Unknown' if null
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'PHONE NUMBER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'Unknown', // Fallback to 'Unknown' if null
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      profilePicture
                                          .toString(), // Convert to string in case it's null
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit
                                          .cover, // Ensures the image fills the circular area
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'DRIVER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    username
                                        .toString(), // Replace with dynamic license
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'LICENSE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    '${widget.order['plate_number'] ?? 'Unknown'}', // Replace with dynamic license
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'PHONE NUMBER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    '${widget.order['rider'] ?? 'Unknown'}', // Replace with dynamic phone number
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],

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
      ),
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

    // Fallback to a default location if latLng is null
    LatLng initialCenter = latLng ??
        LatLng(
          widget.order['s_location_lat'],
          widget.order['s_location_lng'],
        ); // Default to coordinates (0, 0)

    return SizedBox(
      width: 400,
      height: 300,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: initialCenter, // Use the non-null value of latLng
          initialZoom: 17.0,
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
//nul raider phone number