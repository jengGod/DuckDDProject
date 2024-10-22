import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duckddproject/pages/DriverOrderPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Drivermap extends StatefulWidget {
  final Map<String, dynamic> order;
  const Drivermap({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<Drivermap> createState() => _DrivermapState();
}

class _DrivermapState extends State<Drivermap> {
  final MapController mapController = MapController();
  double lati = 0;
  double long = 0;
  LatLng? latLng;
  LatLng? latLngSend;
  LatLng? latLngReceiver;
  String? phonenumber;
  Timer? locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    loadUserData();
    startLocationUpdates();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phonenumber = prefs.getString('phonenumber');
    await updateDriverLocation(); // Update location on load
  }

  Future<void> updateDriverLocation() async {
    if (phonenumber == null) return;

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      lati = position.latitude;
      long = position.longitude;

      // Update Firestore with the new location
      await FirebaseFirestore.instance.collection('Driver_location').doc(phonenumber).set({
        'location_loti': lati,
        'location_long': long,
      });

      // Update the LatLng and move the map only if latLng is valid
      setState(() {
        latLng = LatLng(lati, long);
        log('Updated Location: lati: $lati, long: $long');
      });

      // Only move the map if latLng is not null
      if (latLng != null) {
        mapController.move(latLng!, 15.0);
      }
    } catch (e) {
      log('Error updating location: $e');
    }
  }

  void startLocationUpdates() {
    locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await updateDriverLocation();
    });
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back to order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DriverOrderPage(order: widget.order)),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child: showMap()),
          ],
        ),
      ),
    );
  }

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
}
