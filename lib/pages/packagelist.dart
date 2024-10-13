import 'package:duckddproject/pages/UserHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class Packagelist extends StatefulWidget {
  const Packagelist({super.key});

  @override
  State<Packagelist> createState() => _PackagelistState();
}

class _PackagelistState extends State<Packagelist> {
  LatLng? latLng;
  MapController mapController = MapController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // เรียกฟังก์ชันหาตำแหน่งปัจจุบัน
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
        title: const Text('เลือกตำแหน่งบนแผนที่'),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // แสดงวงกลมโหลดหากยังหาตำแหน่งไม่เจอ
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: latLng!,
                      initialZoom: 15.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          latLng = point; // อัปเดตตำแหน่งเมื่อคลิกแผนที่
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        // ส่งค่าพิกัดกลับไปและ pop ออกจากหน้า
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserHomePage()),
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
