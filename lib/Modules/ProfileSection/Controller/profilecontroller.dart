import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/utils/api_endpoints.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = UserData().obs;

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      String accessToken = await SharedPre.getAccessToken();
      String refreshToken = await SharedPre.getRefreshToken();

      if (accessToken.isEmpty) {
        debugPrint("Access token is empty ❌");
        return;
      }

      final url = ApiEndpoint.getUrl(ApiEndpoint.profile);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Accept": "application/json",
          "x-refresh-token": refreshToken,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = ProfileResponse.fromJson(jsonDecode(response.body));
        profileData.value = json.data ?? UserData();
      }
    } catch (e) {
      debugPrint("Profile API Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchProfile();
    fetchProfile().then((_) {
      nameCtrl.text = profileData.value.name ?? "";
      emailCtrl.text = profileData.value.email ?? "";
      addressCtrl.text = profileData.value.location?.address ?? "";
      String genderFromApi = profileData.value.gender?.toLowerCase() ?? "male";
      if (!genders.contains(genderFromApi)) {
        genderFromApi = "male"; // अगर backend कुछ अलग भेज दे तो fallback
      }
      selectedGender.value = genderFromApi;
    });
    super.onInit();
  }

  var imageFile = Rx<File?>(null);

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  var selectedGender = "male".obs;
  var selectedDOB = Rx<DateTime?>(null);
  final genders = ["male", "female", "other"];

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      imageFile.value = File(picked.path);
    }
  }

  Future<void> updateProfileApi() async {
    try {
      isLoading.value = true;
      String accessToken = await SharedPre.getAccessToken();
      var uri = Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.updateProfile));

      var request = http.MultipartRequest("PATCH", uri);
      request.headers.addAll({
        "Authorization": "Bearer $accessToken",
        "Accept": "application/json",
      });

      if (imageFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath("profile", imageFile.value!.path),
        );
      }

      // पुरानी values fallback
      String oldName = profileData.value.name ?? "";
      String oldEmail = profileData.value.email ?? "";
      String oldGender = profileData.value.gender ?? "male";
      String oldDob = profileData.value.dob ?? "1999-01-01T00:00:00.000Z";
      String oldAddress = profileData.value.location?.address ?? "";

      // अगर user ने field नहीं भरी तो पुरानी भेजो
      request.fields.addAll({
        "name": nameCtrl.text.trim().isNotEmpty
            ? nameCtrl.text.trim()
            : oldName,
        "email": emailCtrl.text.trim().isNotEmpty
            ? emailCtrl.text.trim()
            : oldEmail,
        "gender": selectedGender.value.toLowerCase().isNotEmpty
            ? selectedGender.value.toLowerCase()
            : oldGender,
        "dob": selectedDOB.value != null
            ? "${selectedDOB.value!.year}-${selectedDOB.value!.month.toString().padLeft(2, '0')}-${selectedDOB.value!.day.toString().padLeft(2, '0')}T00:00:00.000Z"
            : oldDob,
        "address": addressCtrl.text.trim().isNotEmpty
            ? addressCtrl.text.trim()
            : oldAddress,
        "lat": "28.5559",
        "lng": "77.3466",
      });

      var response = await request.send();
      var resBody = await response.stream.bytesToString();
      var jsonRes = jsonDecode(resBody);

      if (jsonRes["success"] == true) {
        Get.snackbar("Success", "Profile updated successfully ✔");
        Get.offAll(() => const BottomNavBar(initialIndex: 3));
      } else {
        Get.snackbar("Failed", jsonRes["message"] ?? "Update failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
