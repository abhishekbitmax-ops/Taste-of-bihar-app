import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/AddAddress.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/UpdateAddrsss.dart';

class DeliveryLocationScreen extends StatefulWidget {
  final String? editAddressId;

  const DeliveryLocationScreen({super.key, this.editAddressId});

  @override
  State<DeliveryLocationScreen> createState() => _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState extends State<DeliveryLocationScreen> {
  final MapController _mapController = MapController();
  final Authcontroller addressCtrl = Get.put(Authcontroller());

  final String googleApiKey = "AIzaSyATQ_YYpnU1_tvoyRis0mmZPv8ifP2qbbM";

  LatLng selectedLocation = const LatLng(28.6139, 77.2090);
  String currentAddress = "Fetching location...";

  final TextEditingController searchController = TextEditingController();
  List<dynamic> predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// 📍 GET CURRENT LOCATION
  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    selectedLocation = LatLng(pos.latitude, pos.longitude);
    _mapController.move(selectedLocation, 16);
    fetchAddress(selectedLocation);
  }

  /// 🏠 REVERSE GEOCODING
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
        currentAddress = data["display_name"] ?? "No address found";
      });
    }
  }

  /// 🔍 GOOGLE AUTOCOMPLETE (INDIA ONLY)
  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => predictions.clear());
      return;
    }

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&components=country:in"
        "&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        predictions = data["predictions"];
      });
    }
  }

  /// 📌 GET LAT LNG FROM PLACE
  Future<void> selectPlace(String placeId, String description) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)["result"];
      final location = result["geometry"]["location"];

      final latLng = LatLng(location["lat"], location["lng"]);
      _mapController.move(latLng, 17);

      setState(() {
        selectedLocation = latLng;
        currentAddress = description;
        predictions.clear();
        searchController.clear();
      });

      addressCtrl.setLocation(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );
    }
  }

  /// ❌ CLEAR SEARCH
  void clearSearch() {
    searchController.clear();
    setState(() => predictions.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Delivery Location"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          /// 🗺 MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                selectedLocation = point;
                fetchAddress(point);
                addressCtrl.setLocation(
                  latitude: point.latitude,
                  longitude: point.longitude,
                );
                setState(() {});
              },
            ),
            children: [
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

          /// 🔍 SEARCH BOX
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search area, street, sector...",
                      border: InputBorder.none,
                      icon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: clearSearch,
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {}); // refresh suffix icon

                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 400), () {
                        searchPlaces(value);
                      });
                    },
                  ),
                ),

                if (predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        final p = predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(p["description"]),
                          onTap: () =>
                              selectPlace(p["place_id"], p["description"]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          /// ⬇ BOTTOM CARD
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

                      // If this screen was opened for editing an existing address,
                      // navigate to Updateaddrsss, otherwise go to AddAddress.
                      if (widget.editAddressId != null &&
                          widget.editAddressId!.isNotEmpty) {
                        Get.to(
                          () => Updateaddrsss(addressId: widget.editAddressId!),
                        );
                      } else {
                        Get.to(const AddAddressScreen());
                      }
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
