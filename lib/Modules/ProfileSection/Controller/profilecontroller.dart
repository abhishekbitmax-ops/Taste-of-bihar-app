import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:taste_of_bihar/Modules/Navbar/navbar.dart';
import 'package:taste_of_bihar/Modules/ProfileSection/view/profilemodel.dart';
import 'package:taste_of_bihar/utils/Sharedpre.dart';
import 'package:taste_of_bihar/utils/api_endpoints.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = UserData().obs;

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      String accessToken = await SharedPre.getAccessToken();
      String refreshToken = await SharedPre.getRefreshToken();

      if (accessToken.isEmpty) {
        debugPrint("Access token is empty");
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
        genderFromApi = "male";
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
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (picked != null) {
      imageFile.value = File(picked.path);
      final fileSizeInBytes = await imageFile.value!.length();
      debugPrint(
        "pickImage selected file size: ${(fileSizeInBytes / 1024).toStringAsFixed(2)} KB",
      );
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
        final ext = path.extension(imageFile.value!.path).toLowerCase();

        MediaType mediaType = ext == '.png'
            ? MediaType('image', 'png')
            : MediaType('image', 'jpeg');

        request.files.add(
          await http.MultipartFile.fromPath(
            "profile",
            imageFile.value!.path,
            contentType: mediaType,
          ),
        );
      }

      String oldName = profileData.value.name ?? "";
      String oldEmail = profileData.value.email ?? "";
      String oldGender = profileData.value.gender ?? "male";
      String oldDob = profileData.value.dob ?? "1999-01-01T00:00:00.000Z";
      String oldAddress = profileData.value.location?.address ?? "";

      request.fields.addAll({
        "name": nameCtrl.text.trim().isNotEmpty
            ? nameCtrl.text.trim()
            : oldName,
        "email": emailCtrl.text.trim().isNotEmpty
            ? emailCtrl.text.trim()
            : oldEmail,
        "gender": selectedGender.value.isNotEmpty
            ? selectedGender.value.toLowerCase()
            : oldGender,
        "dob": selectedDOB.value != null
            ? "${selectedDOB.value!.year}-${selectedDOB.value!.month.toString().padLeft(2, '0')}-${selectedDOB.value!.day.toString().padLeft(2, '0')}T00:00:00.000Z"
            : oldDob,
        "addresses[0][type]": "home",
        "addresses[0][street]": addressCtrl.text.trim().isNotEmpty
            ? addressCtrl.text.trim()
            : oldAddress,
        "addresses[0][coordinates][lat]": "28.5559",
        "addresses[0][coordinates][lng]": "77.3466",
      });

      debugPrint("updateProfileApi url: $uri");
      debugPrint("updateProfileApi headers: ${request.headers}");
      debugPrint("updateProfileApi fields: ${request.fields}");
      debugPrint(
        "updateProfileApi file: ${imageFile.value?.path ?? "No image selected"}",
      );
      if (imageFile.value != null) {
        final fileSizeInBytes = await imageFile.value!.length();
        debugPrint(
          "updateProfileApi file size: ${(fileSizeInBytes / 1024).toStringAsFixed(2)} KB",
        );
      }

      var response = await request.send();
      var resBody = await response.stream.bytesToString();

      debugPrint("updateProfileApi status code: ${response.statusCode}");
      debugPrint("updateProfileApi raw response: $resBody");

      dynamic jsonRes;
      if (resBody.isNotEmpty) {
        try {
          jsonRes = jsonDecode(resBody);
        } catch (_) {
          jsonRes = null;
        }
      }
      debugPrint("updateProfileApi decoded response: $jsonRes");

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          jsonRes is Map<String, dynamic> &&
          jsonRes["success"] == true) {
        await fetchProfile();
        Get.offAll(() => const BottomNavBar(initialIndex: 3));
      } else if (response.statusCode == 413) {
        Get.snackbar(
          "Image too large",
          "Please choose a smaller profile image and try again.",
        );
      } else {
        final message = jsonRes is Map<String, dynamic>
            ? jsonRes["message"] ?? "Update failed"
            : "Update failed";
        Get.snackbar("Failed", message.toString());
      }
    } catch (e) {
      debugPrint("updateProfileApi error: $e");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
