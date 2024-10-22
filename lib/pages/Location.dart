import 'package:duckddproject/pages/RegisterUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  LatLng? latLng; // เก็บตำแหน่งพิกัด
  final MapController mapController = MapController(); // ควบคุมแผนที่
  bool isLoading = true; 

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
  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลผู้ใช้เมื่อเริ่มต้น
    _determinePosition(); // หาตำแหน่งปัจจุบันเมื่อเริ่มต้น
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
            MaterialPageRoute(builder: (context) => const Registeruser()),
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
                            latLng = point; // Update the latLng to the tapped point
                            mapController.move(latLng!, 15.0); // Move the map to the new location
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
                      // Pass the latLng to the Registeruser page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Registeruser(
                            selectedLocation: latLng, // Passing latLng
                          ),
                        ),
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
