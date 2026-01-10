import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/view/AddAddress.dart';

class DeliveryLocationScreen extends StatefulWidget {
  const DeliveryLocationScreen({super.key});

  @override
  State<DeliveryLocationScreen> createState() => _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState extends State<DeliveryLocationScreen> {
  final MapController _mapController = MapController();
  final Authcontroller addressCtrl = Get.put(Authcontroller());

  LatLng selectedLocation = LatLng(28.6139, 77.2090);
  String currentAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
  }

  /// ---------------- GET CURRENT GPS LOCATION ----------------
  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      selectedLocation = LatLng(pos.latitude, pos.longitude);
    });

    _mapController.move(selectedLocation, 16);
    fetchAddress(selectedLocation);
  }

  /// ---------------- FETCH ADDRESS (Reverse Geocoding) ----------------
  Future<void> fetchAddress(LatLng pos) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json",
    );

    final response = await http.get(
      url,
      headers: {"User-Agent": "Flutter App"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        currentAddress = data["display_name"] ?? "No address";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// MAP VIEW
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });

                addressCtrl.setLocation(
                  latitude: point.latitude,
                  longitude: point.longitude,
                );

                fetchAddress(point);
              },
            ),
            children: [
              /// --- FIXED TILE SERVER ---
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_pin,
                      size: 45,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// BOTTOM
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirm Delivery Location",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    currentAddress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      addressCtrl.setLocation(
                        latitude: selectedLocation.latitude,
                        longitude: selectedLocation.longitude,
                      );
                      Get.to(const AddAddressScreen());
                    },

                    child: const Text(
                      "Select Location",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
