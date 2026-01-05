import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';

class UserBasicDetails extends StatefulWidget {
  const UserBasicDetails({super.key});

  @override
  State<UserBasicDetails> createState() => _UserBasicDetailsState();
}

class _UserBasicDetailsState extends State<UserBasicDetails> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final RxString selectedGender = "".obs;
  final RxString dobValue = "".obs;
  final RxString locationTime = "".obs;
  final Authcontroller userBasicCtrl = Get.put(Authcontroller());

  File? userImage;
  final ImagePicker picker = ImagePicker();

  // 📸 Pick user image from gallery
  Future<void> _pickUserImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        userImage = File(img.path);
      });
    }
  }

  // 📍 Fetch current location + time
  Future<void> _fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Location Error", "Please enable GPS service");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission is required");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Error", "Enable permission from settings.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> place = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String address =
        "${place.first.street ?? ""}, ${place.first.locality ?? ""}, ${place.first.country ?? ""}";
    String fetchTime = DateFormat('hh:mm a').format(DateTime.now());

    locationCtrl.text = address;
    locationTime.value = fetchTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(50),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.arrow_back, color: Colors.black87, size: 24),
          ),
        ),
        centerTitle: true,
        title: Text(
          "User Basic Details",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B0000),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                children: [
                  // 👤 User Image Picker
                  GestureDetector(
                    onTap: _pickUserImage,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: userImage != null
                          ? FileImage(userImage!)
                          : null,
                      child: userImage == null
                          ? const Icon(
                              Icons.add_a_photo,
                              size: 30,
                              color: Colors.black54,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Name Field
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Full Name",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email Field
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: const Icon(
                        Icons.email,
                        size: 20,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // DOB Picker
                  Obx(
                    () => InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 6570),
                          ),
                          firstDate: DateTime(1940),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dobValue.value = DateFormat(
                            'yyyy-MM-dd',
                          ).format(picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              dobValue.value.isEmpty
                                  ? "Date of Birth"
                                  : dobValue.value,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Gender Dropdown
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButton<String>(
                        value: selectedGender.value.isEmpty
                            ? null
                            : selectedGender.value,
                        hint: Text(
                          "Gender",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (val) => selectedGender.value = val!,
                        items: const ["Male", "Female", "Other"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Field + GPS + Time
                  Obx(
                    () => TextField(
                      controller: locationCtrl,
                      readOnly: false, // ✍ allows manual typing
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Location",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: _fetchLocation,
                              child: const Icon(
                                Icons.my_location,
                                color: Color(0xFF8B0000),
                              ),
                            ),
                            if (locationTime.value.isNotEmpty)
                              Text(
                                locationTime.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Continue Button
                  SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: () {
                        userBasicCtrl.submitBasicDetails(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          imageFile: userImage,
                          gender: selectedGender.value.toLowerCase(),
                          dob: dobValue.value,
                          address: locationCtrl.text.trim(),
                          lat: 28.5559,
                          lng: 77.3466,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        "Continue",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
