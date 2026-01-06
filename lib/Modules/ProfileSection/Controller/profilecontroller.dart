import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var profileData = UserData().obs;

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      String token = await SharedPre.getAccessToken();
      final url = ApiEndpoint.getUrl(ApiEndpoint.profile);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
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
    super.onInit();
  }
}
