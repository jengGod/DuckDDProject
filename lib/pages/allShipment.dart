import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/packagelist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class AllshipmentPage extends StatefulWidget {
  const AllshipmentPage({super.key});

  @override
  State<AllshipmentPage> createState() => _nameState();
}

class _nameState extends State<AllshipmentPage> {
  final MapController mapController = MapController(); // ควบคุมแผนที่
  bool isLoading = true;

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
      body: showMap(), // Use the body property to display the map
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
        child:  const Icon(
          Icons.flag, // Red pin for receiver
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
        child:  const Icon(
          Icons.location_on, // Green flag for sender
          color: Colors.red,
          size: 40,
        ),
      ),
    );

    return SizedBox(
      width: 400, // Set the desired width
      height: 800, // Set the desired height
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
    );
  }
}
