import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/LoginPage.dart';
import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:duckddproject/pages/reciverListPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  TextEditingController packageNameCtl = TextEditingController();
  TextEditingController packageDescriptionCtl = TextEditingController();

  int selectedIndex = 0;

  String? selectedUsername;
  String? selectedPhoneNumber;

  LatLng? latLng;
  LatLng? latLngSend;

  MapController mapController = MapController();

  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;

  double lati = 0;
  double long = 0;
  double latiSend = 0;
  double longSend = 0;

  Future<void> openReciverList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Reciverlistpage()),
    );
    if (result != null) {
      setState(() {
        selectedUsername = result['username'];
        selectedPhoneNumber = result['phonenumber'];
        loadLocation();
      });
    }
  }

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
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
              label: 'list',
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
                    MaterialPageRoute(builder: (context) => UserHomePage()),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 60,
                        color: Colors.black45,
                      ),
                      onPressed: () {
                        print('Cloud upload clicked');
                      },
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: 60,
                        color: Colors.black45,
                      ),
                      onPressed: () {
                        print('Camera icon clicked');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: packageNameCtl,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: packageDescriptionCtl,
                decoration: const InputDecoration(
                  labelText: 'Package Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: openReciverList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize:
                      const Size(double.infinity, 50), // ปรับความกว้างให้เต็ม
                ),
                child: const Text(
                  'Choose Receiver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (selectedUsername != null && selectedPhoneNumber != null) ...[ //--------------------------*map here
                Text('Receiver name: $selectedUsername'),
                Text('Receiver phonenumber: $selectedPhoneNumber'),
                const SizedBox(height: 16),
                showMap(),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _showConfirmDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Send package',
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

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Confirm order?'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                //-------------------------------------------------------------get location
                Navigator.of(context).pop();
                Confirm(context);
              },
              child: const Text('Confirm'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void Confirm(BuildContext context) {
    addOrder();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            // To avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min, // Reduce height to fit content
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('COMPLETE SEND ORDER!!!'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadLocation() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      log(selectedPhoneNumber.toString());
      DocumentSnapshot locationDoc =
          await firestore.collection('Users_location').doc(selectedPhoneNumber).get();
      DocumentSnapshot locationSenderDoc =
          await firestore.collection('Users_location').doc(phonenumber).get();
      if (locationDoc.exists && locationSenderDoc.exists) {
        setState(() {
          lati = locationDoc['location_loti'];
          long = locationDoc['location_long'];
          latiSend = locationSenderDoc['location_loti'];
          longSend = locationSenderDoc['location_long'];
        });
      }
    } catch (e) {
      log('Error: $e');
    }
    log('Location:');
    log(lati.toString());
    log(long.toString());
    log(latiSend.toString());
    log(longSend.toString());
  }

  Widget showMap() {
    try {
      setState(() {
        latLng = LatLng(lati, long);
        latLngSend = LatLng(latiSend, longSend);
      });
      mapController.move(latLng!, 14.0);
    } catch (e) {}

    return SizedBox(
      width: 400, // Set the desired width
      height: 200, // Set the desired height
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
          if (latLng != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: latLng!,
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
          if(latLngSend != null)
          MarkerLayer(
              markers: [
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
              ],
            ),
        ],
      ),
    );
  }

  Future<void> addOrder() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var db = FirebaseFirestore.instance;
  DocumentReference counterRef = firestore.collection('Counters').doc('order_counter');
  // Run a transaction to prevent race conditions
  firestore.runTransaction((transaction) async {
    // Get the current running number
    DocumentSnapshot snapshot = await transaction.get(counterRef);
    if (!snapshot.exists) {
      throw Exception("Counter document does not exist!");
    }

    int currentNumber = snapshot.get('running_number');

    // Increment the running number and update the counter document
    int newNumber = currentNumber + 1;
    transaction.update(counterRef, {'running_number': newNumber});
  }).catchError((error) {
    print("Failed to add order: $error");
  });

   var data = {
      'sender': phonenumber.toString(),
      'receiver':selectedPhoneNumber.toString(),
      'r_location_lat':lati, 
      'r_location_lng':long,
      's_location_lat':latiSend, 
      's_location_lng':longSend,
      'pic_1':"",
      'pic_2':"",
      'name':packageNameCtl.text,
      'descrip':packageDescriptionCtl.text,
      'rider':"",
      'plate_number':"",
      'order_status':"1"
    };

    try {
      log('Start Order');
      DocumentSnapshot orderNum = await firestore.collection('Counters').doc('order_counter').get();
      String orderID = orderNum['running_number'].toString();
      db.collection('Orders').doc(orderID).set(data);
    } catch (e) {
      log(e.toString());
      //รูป
      //ดักปุ่ม
    }
}

}
