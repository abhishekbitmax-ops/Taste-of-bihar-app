import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:restro_app/utils/Sharedpre.dart';
import 'dart:convert';

class EditProfileController extends GetxController {
  var imageFile = Rx<File?>(null);
  var locationText = "".obs;
  var isLoading = false.obs;

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  var selectedGender = "Male".obs;
  var selectedDOB = Rx<DateTime?>(null); // ✔ now observable

  final genders = ["Male", "Female", "Other"];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationText.value = "Location disabled";
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        locationText.value = "Permission denied";
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      locationText.value = "Permission denied forever";
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;
    locationText.value = "${place.street}, ${place.locality}";
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ctrl = Get.put(EditProfileController());

  @override
  void initState() {
    super.initState();
    ctrl.fetchCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8B0000),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        // ✔ prevents DOB error + overflow
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => ctrl.pickImage(),
                child: Obx(
                  () => CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: ctrl.imageFile.value != null
                        ? FileImage(ctrl.imageFile.value!)
                        : null,
                    child: ctrl.imageFile.value == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Color(0xFF8B0000),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              buildTextField(
                "Name",
                TextField(
                  controller: ctrl.nameCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              buildTextField(
                "Mobile",
                TextField(
                  controller: ctrl.mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              buildTextField(
                "Email",
                TextField(
                  controller: ctrl.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              buildTextField(
                "Gender",
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: ctrl.selectedGender.value,
                    items: ctrl.genders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) =>
                        ctrl.selectedGender.value = val ?? "Male",
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              buildTextField(
                "DOB",
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      ctrl.selectedDOB.value = picked; // ✔ update observable
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Obx(
                          () => Text(
                            ctrl.selectedDOB.value != null
                                ? "${ctrl.selectedDOB.value!.day}/${ctrl.selectedDOB.value!.month}/${ctrl.selectedDOB.value!.year}"
                                : "Select DOB",
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Color(0xFF8B0000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isLoading.value ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                  ),
                  child: ctrl.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String title, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }
}
