import 'dart:developer';

import 'package:duckddproject/pages/UserHome.dart';
import 'package:duckddproject/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Changelocation extends StatefulWidget {
  const Changelocation({super.key});

  @override
  State<Changelocation> createState() => _ChangelocationState();
}

class _ChangelocationState extends State<Changelocation> {
  String? username;
  String? email;
  String? phonenumber;
  String? profilePicture;
  String? password;
  LatLng? latLng; // เก็บตำแหน่งพิกัด
  final MapController mapController = MapController(); // ควบคุมแผนที่
  bool isLoading = true; // ใช้แสดงการโหลดตำแหน่งปัจจุบัน

  @override
  void initState() {
    super.initState();
    loadUserData(); // โหลดข้อมูลผู้ใช้เมื่อเริ่มต้น
    _determinePosition(); // หาตำแหน่งปัจจุบันเมื่อเริ่มต้น
  }

  // ฟังก์ชันเพื่อหาตำแหน่งปัจจุบัน
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่าบริการ GPS เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
      latLng = LatLng(position.latitude, position.longitude); // ตั้งค่าพิกัดตำแหน่งปัจจุบัน
      isLoading = false; // หยุดแสดงการโหลด
    });
    mapController.move(latLng!, 15.0); // ขยับแผนที่ไปยังตำแหน่งปัจจุบัน
  }

  // ฟังก์ชันเพื่ออัปเดตตำแหน่งใน Firestore
 Future<void> _updateLocationInFirestore() async {
    if (latLng != null) {
      var locationUser = {
        'location_loti': latLng!.latitude,
        'location_long': latLng!.longitude,
      };

      // แสดงพิกัดที่เลือกในคอนโซล
      // [log] Updating location: Latitude: 16.236811332298203, Longitude: 103.26796586408476
      log("Updating location: Latitude: ${latLng!.latitude}, Longitude: ${latLng!.longitude}");

      // เพิ่ม print statement เพื่อตรวจสอบว่าเริ่มการอัปเดตหรือไม่
      print("Starting Firestore update...");

      // อัปเดตข้อมูลใน Firestore โดยใช้หมายเลขโทรศัพท์เป็นเอกลักษณ์
      await FirebaseFirestore.instance
          .collection('Users_location')
          .doc(phonenumber)
          .set(locationUser)
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ตำแหน่งถูกอัปเดตเรียบร้อย')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
        );
      });
    }
}


  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phonenumber = prefs.getString('phonenumber');
      profilePicture = prefs.getString('profile_picture');
      String? oldPassword = prefs.getString('password'); // โหลดรหัสผ่านเก่า
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('เลือกตำแหน่งบนแผนที่'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const userProfile()),
          );
        },
      ),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                   initialCenter: latLng ?? LatLng(0, 0), // Use initial center if latLng is null
                   initialZoom: 16.0, // Set initial zoom level
                        onTap: (tapPosition, point) {
                          setState(() {
                            latLng =
                                point; // Update the latLng to the tapped point
                            // log("Selected location: Latitude: ${point.latitude}, Longitude: ${point.longitude}");
                            mapController.move(latLng!,
                                15.0); // Move the map to the new location
                            // log("Updated latLng: Latitude: ${latLng!.latitude}, Longitude: ${latLng!.longitude}"); // Log updated latLng
                          });
                        }

                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      maxNativeZoom: 35,
                    ),
                    if (latLng != null) // Display the marker if latLng is not null
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLng!, // Use the updated latLng
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
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (latLng != null) {
                      print("Button pressed, calling _updateLocationInFirestore");
                      _updateLocationInFirestore(); // Update the location in Firestore
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => userProfile()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณาเลือกตำแหน่งก่อน'),
                        ),
                      );
                    }
                  },
                  child: const Text('ตกลง'),
                ),
              ),
            ],
          ),
  );
}

}
