import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restro_app/Modules/Dashboard/view/AddAddress.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? mapController;
  LatLng? currentLatLng;
  String address = "";
  bool isFetching = true;

  Future<void> getCurrentLocation({bool moveCamera = true}) async {
    setState(() {
      isFetching = true;
      address = "";
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => isFetching = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => isFetching = false);
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLatLng = LatLng(pos.latitude, pos.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    Placemark place = placemarks.first;

    String newAddress = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ].where((e) => e != null && e!.isNotEmpty).join(", ");

    setState(() {
      address = newAddress;
      currentLatLng = currentLatLng;
      isFetching = false;
    });

    if (moveCamera && moveCamera) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng!, 16),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // TOP HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Select Your Location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // MAP VIEW (REAL)
                Expanded(
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 16,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (c) {
                          mapController = c;
                        },
                        onCameraMove: (pos) {
                          currentLatLng = pos.target;
                          debounceUpdateAddress();
                        },
                      ),

                      // CENTER PIN (DRAGGABLE EFFECT)
                      const Center(child: Icon(Icons.location_pin, size: 46)),

                      // REFRESH BUTTON
                      Positioned(
                        bottom: 100,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () => getCurrentLocation(moveCamera: true),
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),

                // ADDRESS DISPLAY (Dynamic)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: isFetching
                      ? const Row(
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 10),
                            Text("Fetching current address…"),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address.isEmpty
                                    ? "Location selected…"
                                    : address,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                // CONFIRM BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 50,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000), // background color
                        foregroundColor: Colors.white, // text color
                      ),
                      onPressed: () {
                        //   Get.back();
                        Get.to(
                          () => const AddAddressScreen(),
                          arguments: {
                            "lat": currentLatLng!.latitude,
                            "lng": currentLatLng!.longitude,
                            "address": address,
                          },
                        );
                      },

                      child: const Text("Confirm Location"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Debounce to avoid fast API calls
  Timer? timer;
  void debounceUpdateAddress() {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 600), () async {
      if (currentLatLng == null) return;
      List<Placemark> marks = await placemarkFromCoordinates(
        currentLatLng!.latitude,
        currentLatLng!.longitude,
      );
      setState(() {
        address = marks.first.name ?? "";
      });
    });
  }
}
