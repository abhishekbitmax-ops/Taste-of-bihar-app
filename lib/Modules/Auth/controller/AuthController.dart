import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/view/Otpverifiction.dart';
import 'package:http/http.dart' as http;
import 'package:restro_app/Modules/Auth/view/basicdetails.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'dart:convert';

import 'package:restro_app/utils/api_endpoints.dart';

class Authcontroller extends GetxController {
  final mobileCtrl = TextEditingController();
  var isLoading = false.obs;

  Future<void> sendOtp() async {
    if (mobileCtrl.text.length < 10) {
      Get.snackbar("Error", "Please enter valid mobile number");
      return;
    }

    try {
      isLoading.value = true;

      var body = jsonEncode({"mobile": mobileCtrl.text.trim()});

      var response = await http.post(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.login)),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      var data = jsonDecode(response.body);
      debugPrint(data.toString());

      if (data["success"] == true) {
        Get.to(
          () => const OtpVerificationScreen(),

          arguments: {"mobile": mobileCtrl.text.trim()},
        );
      } else {
        Get.snackbar("Failed", data["message"] ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP ------

  Future<void> verifyOtp({required String mobile, required String otp}) async {
    try {
      isLoading.value = true;

      final url = ApiEndpoint.getUrl(ApiEndpoint.verifyOtp);
      final body = jsonEncode({"mobile": mobile, "otp": otp});

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final data = jsonDecode(response.body);
      debugPrint(data.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        await SharedPre.saveMobile(mobile); // 👈 SAVE VERIFIED MOBILE

        Get.snackbar(
          "Success",
          "OTP Verified Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.to(() => const UserBasicDetails());
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Invalid OTP",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Exception",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Submit Basic Details------------

  Future<void> submitBasicDetails({
    required String name,
    required String email,
    required File? imageFile,
    required String gender,
    required String dob,
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      isLoading.value = true;
      final url = ApiEndpoint.getUrl(ApiEndpoint.basicDetails);

      var request = http.MultipartRequest('POST', Uri.parse(url));

      final mobile = await SharedPre.getMobile(); // 👈 GET SAVED MOBILE
      if (mobile.isEmpty) {
        Get.snackbar(
          "Error",
          "No verified mobile found in storage",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      request.fields['mobile'] = mobile;

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['gender'] = gender;
      request.fields['dob'] = dob;
      request.fields['location'] = jsonEncode({
        "address": address,
        "lat": lat,
        "lng": lng,
      });

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile', imageFile.path),
        );
      }

      var response = await request.send();
      var resBody = await response.stream.bytesToString();
      var data = jsonDecode(resBody);
      debugPrint(data.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Details submitted successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAll(BottomNavBar());
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Submission failed",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Exception",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
