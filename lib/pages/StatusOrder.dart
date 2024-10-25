import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statusorder extends StatefulWidget {
  final Map<String, dynamic> order;

  const Statusorder({Key? key, required this.order}) : super(key: key);

  @override
  State<Statusorder> createState() => _StatusorderState();
}

class _StatusorderState extends State<Statusorder> {
  Map<String, dynamic>? orderData;
  Map<String, dynamic>? orderlocationData;

  StreamSubscription? listener;
  StreamSubscription? Driverlistener;
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
    startRealtimeGet();
    startRealtimeGetlocation();
    if (widget.order['order_status'] == "4") {
      stopUpdates();
    } else {
      driverLocation();
      startLocationUpdates();
    }
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
          lati = orderlocationData?['location_loti'] ??
              0.0; // Provide default values if necessary
          long = orderlocationData?['location_long'] ?? 0.0;
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

  void stopUpdates() {
    locationTimer?.cancel(); // Stop the periodic timer
    _isUpdatingLocation = false; // Reset the flag
  }

  void startRealtimeGet() {
    var db = FirebaseFirestore.instance;

    final docRef = db.collection("Orders").doc(widget.order['orderId']);
    listener = docRef.snapshots().listen(
      (event) {

        var data = event.data();
        if (data != null) {
          setState(() {
            loadUserData();
            orderData = data;
            // เก็บข้อมูลใหม่ในตัวแปร
          });
          log("current data: ${event.data()}");
        } else {
          log('No data found for the document');
        }
      },
      onError: (error) => log("Listen failed: $error"),
    );

    // log แสดงรายละเอียดของ listener (ไม่แนะนำให้ใช้ toString() ตรงๆ)
    log('Listener created: $listener');
  }
   void startRealtimeGetlocation() {
    var db = FirebaseFirestore.instance;

    final docRef = db.collection("Driver_location").doc(widget.order['rider']);
    Driverlistener = docRef.snapshots().listen(
      (event) {
        var data = event.data();
        if (data != null) {
          setState(() {
            orderlocationData = data;
            // เก็บข้อมูลใหม่ในตัวแปร
          });
          log("current data: ${event.data()}");
        } else {
          log('No data found for the document');
        }
      },
      onError: (error) => log("Listen failed: $error"),
    );

    // log แสดงรายละเอียดของ listener (ไม่แนะนำให้ใช้ toString() ตรงๆ)
    log('Listener created: $listener');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ติดตามสถานะจัดส่ง'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            stopRealTimelocation();
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
                        SingleChildScrollView(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'SEARCH OF DRIVER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                      color: orderData?['order_status'] == "1"
                                          ? Colors.green // สีเมื่อสถานะเป็น 1
                                          : Colors.black, // สีปกติ
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  if (orderData?['order_status'] == "1") ...[
                                    Image.asset(
                                      'assets/image/duck.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'PICKUP PACKAGE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                      color: orderData?['order_status'] == "2"
                                          ? Colors.orange
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  if (orderData?['order_status'] == "2") ...[
                                    Image.asset(
                                      'assets/image/duck.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'DELIVERING',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                      color: orderData?['order_status'] == "3"
                                          ? Colors.orange
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  if (orderData?['order_status'] == "3") ...[
                                    Image.asset(
                                      'assets/image/duck.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'DELIVERED',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                      color: orderData?['order_status'] == "4"
                                          ? Colors.orange
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  if (orderData?['order_status'] == "4") ...[
                                    Image.asset(
                                      'assets/image/duck.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 20),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        if (orderData?['rider'] == null ||
                            orderData?['rider'].isEmpty) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
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
                                  Text(
                                    'LICENSE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'Unknown', // Fallback to 'Unknown' if null
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'PHONE NUMBER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    'Unknown', // Fallback to 'Unknown' if null
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                        if ((orderData?['rider'] != null &&
                            orderData?['rider'].isNotEmpty)) ...[
                          if (profilePicture == null ||
                              profilePicture.toString().isEmpty ||
                              username == null ||
                              username.toString().isEmpty) ...[
                            // Center(
                            //   child:
                            //       CircularProgressIndicator(), // Show loading spinner while data is being loaded
                            // ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    ClipOval(
                                      child: Image.network(
                                        profilePicture
                                            .toString(), // Display profile picture
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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
                                      username.toString(), // Display username
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
                                      '${orderData?['plate_number'] ?? 'Unknown'}', // Display plate number or fallback to 'Unknown'
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
                                      '${orderData?['rider'] ?? 'Unknown'}', // Display rider's phone number or fallback to 'Unknown'
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ]
                        ],

                        // Button for checking package picture
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Show a pop-up dialog to view the package picture
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Package Picture'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Check order_status and display the corresponding image
                                        if (orderData != null)
                                          if (orderData!['order_status'] == "1" ||
                                              orderData!['order_status'] == "2")
                                            // Show pic_1 for status 1 or 2
                                            orderData?['pic_1'] != null &&
                                                    orderData?['pic_1']
                                                        .isNotEmpty
                                                ? Image.network(
                                                    orderData?['pic_1'],
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                    width: double.infinity,
                                                  )
                                                : const Text(
                                                    'No image available for pic_1.')
                                          else if (orderData!['order_status'] == "3")
                                            // Show pic_2 for status 3
                                            orderData?['pic_2'] != null &&
                                                    orderData?['pic_2']
                                                        .isNotEmpty
                                                ? Image.network(
                                                    orderData?['pic_2'],
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                    width: double.infinity,
                                                  )
                                                : const Text(
                                                    'No image available for pic_2.')
                                          else if (orderData!['order_status'] == "4")
                                            // Show pic_3 for status 4
                                            orderData?['pic_3'] != null &&
                                                    orderData?['pic_3']
                                                        .isNotEmpty
                                                ? Image.network(
                                                    orderData?['pic_3'],
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                    width: double.infinity,
                                                  )
                                                : const Text(
                                                    'No image available for pic_3.'),
                                        const SizedBox(height: 10),
                                         Text(
                                          orderData?['descrip'], // Adjust as needed
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('CHECK PACKAGE PICTURE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey, // Button color
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),
                        FilledButton(
                            onPressed: stopRealTime,
                            child: const Text('Stop Real-time Get')),

                        // Button text
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

  void stopRealTime() {
    if (listener != null) {
      listener!.cancel();
    }
  }
   void stopRealTimelocation() {
    if (Driverlistener != null) {
      Driverlistener!.cancel();
    }
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
      height: 500,
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