import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/view/Otpverifiction.dart';
import 'package:http/http.dart' as http;
import 'package:restro_app/Modules/Auth/view/basicdetails.dart';
import 'package:restro_app/Modules/Dashboard/model/Dashboardmodel.dart';
import 'package:restro_app/Modules/Dashboard/view/CartScreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'package:restro_app/utils/api_endpoints.dart';

class Authcontroller extends GetxController {
  final mobileCtrl = TextEditingController();
  var isLoading = false.obs;
  var isDataBound = false.obs;
  var isBannerLoading = true.obs;
  var isCategoryLoading = true.obs;
  var isHomeRefreshing = false.obs;

  String getCategoryId(CategoryData cat) => cat.id ?? "";

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
    fetchCategories();
    fetchBanners();
  }

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
          arguments: {
            "mobile": data["mobile"],
            "isLogin": false,
            "otp": data["otp"],
          },
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
      debugPrint("OTP Response: $data");

      if (data["success"] == true) {
        await SharedPre.saveMobile(mobile);

        // ✔ Tokens root me mil rhe hain, directly save karo
        await SharedPre.saveTokens(
          accessToken: data["accessToken"] ?? "",
          refreshToken: data["refreshToken"] ?? "",
          expiresIn: data["expiresIn"] ?? "",
        );

        Get.snackbar(
          "Success",
          "OTP Verified Successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (data["requiresRegistration"] == true) {
          Get.off(() => const UserBasicDetails());
        } else {
          Get.offAll(() => BottomNavBar());
          Future.delayed(const Duration(milliseconds: 400), () {
            Get.find<CartController>().initOrderSocket();
          });
        }
      } else {
        Get.snackbar("Error", data["message"] ?? "Invalid OTP");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
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

      // 📱 Get verified mobile
      final mobile = await SharedPre.getMobile();
      if (mobile.isEmpty) {
        Get.snackbar(
          "Error",
          "No verified mobile found",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 🧾 Request Fields
      request.fields.addAll({
        "mobile": mobile,
        "name": name,
        "email": email,
        "gender": gender,
        "dob": dob,

        "addresses[0][type]": "home",
        "addresses[0][street]": address,
        "addresses[0][coordinates][lat]": lat.toString(),
        "addresses[0][coordinates][lng]": lng.toString(),
      });

      // 📸 Profile Image
      if (imageFile != null) {
        final ext = path.extension(imageFile.path).toLowerCase();

        MediaType mediaType;

        if (ext == '.png') {
          mediaType = MediaType('image', 'png');
        } else if (ext == '.webp') {
          mediaType = MediaType('image', 'webp');
        } else if (ext == '.avif') {
          mediaType = MediaType('image', 'avif');
        } else {
          // default JPG
          mediaType = MediaType('image', 'jpeg');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'profile',
            imageFile.path,
            contentType: mediaType,
          ),
        );
      }

      // 🚀 Send request
      final response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      debugPrint("BASIC DETAILS RESPONSE => $data");

      if (data["success"] == true) {
        // 🔐 Save Tokens
        final tokens = data["tokens"];
        if (tokens != null) {
          await SharedPre.saveTokens(
            accessToken: tokens["accessToken"],
            refreshToken: tokens["refreshToken"],
            expiresIn: tokens["expiresIn"],
          );
        }

        // (Optional) Save user basic info if needed later
        // await SharedPre.saveUserId(data["user"]["_id"]);
        // await SharedPre.saveUserName(data["user"]["name"]);

        Get.snackbar(
          "Success",
          data["message"] ?? "Registration successful",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // 🏠 Redirect to Home
        Get.offAll(() => BottomNavBar());

        Future.delayed(const Duration(milliseconds: 400), () {
          Get.find<CartController>().initOrderSocket();
        });
      } else {
        Get.snackbar(
          "Error",
          data["message"] ?? "Submission failed",
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

  // Mobile Login ------

  // Categories Fetching (Example) -----

  CategoryResponse? categoryResponse;
  var categories = <CategoryData>[].obs; //  dynamic list
  int get length => categories.length;

  Future<void> fetchCategories() async {
    try {
      isCategoryLoading(true);

      String token = await SharedPre.getAccessToken();

      final res = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.categories)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        categoryResponse = CategoryResponse.fromJson(jsonDecode(res.body));
        categories.value = categoryResponse?.data ?? [];
      }
    } catch (e) {
      debugPrint("Category API Error: $e");
    } finally {
      isCategoryLoading(false);
    }
  }

  // categories item show api

  var items = <ItemModel>[].obs;
  var category = CategoryModel().obs;

  Future<void> fetchCategoryItems(String categoryId) async {
    try {
      isLoading.value = true;
      items.clear();

      String token = await SharedPre.getAccessToken();

      var response = await http.get(
        Uri.parse(
          "https://sog.bitmaxtest.com/api/v1/user/categories/$categoryId/items",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = jsonDecode(response.body);
        var data = CategoryItemsResponse.fromJson(jsonData);

        if (data.success == true) {
          category.value = data.data?.category ?? CategoryModel();
          items.value = data.data?.items ?? [];
        }
      } else {
        Get.snackbar("Error", "Failed to load items");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add to Cart Functionality

  var isApiLoading = false.obs;

  Future<Map<String, dynamic>> addToCartApi(
    String menuItemId,
    int quantity,
    String instructions,
  ) async {
    try {
      isApiLoading.value = true;
      String token = await SharedPre.getAccessToken();

      final url = ApiEndpoint.getUrl(ApiEndpoint.Addtocart);

      final body = {
        "menuItemId": menuItemId,
        "quantity": quantity,
        "specialInstructions": instructions,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"] ?? "Item added to cart",
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to add item",
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    } finally {
      isApiLoading.value = false;
    }
  }

  // Add Addresss api method

  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;

  RxString street = "".obs;
  RxString area = "".obs;
  RxString city = "".obs;
  RxString state = "".obs;
  RxString zipCode = "".obs;

  /// -------- SET LOCATION FROM MAP --------
  void setLocation({required double latitude, required double longitude}) {
    lat.value = latitude;
    lng.value = longitude;
  }

  /// -------- CALL ADD ADDRESS API --------
  Future<void> addAddressApi({
    required String label,
    required String landmark,
    required bool isDefault,
  }) async {
    try {
      isLoading.value = true;

      String token = await SharedPre.getAccessToken();

      final body = {
        "label": label,
        "street": street.value,
        "area": area.value,
        "city": city.value,
        "state": state.value,
        "zipCode": zipCode.value,
        "lat": lat.value,
        "lng": lng.value,
        "landmark": landmark,
        "isDefault": isDefault,
      };

      final response = await http.post(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.addAddress)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("📥 STATUS CODE => ${response.statusCode}");
      print("📥 RESPONSE BODY => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.to(CartScreen()); // success
        Get.snackbar("Success", "Address added successfully");
      } else {
        Get.snackbar("Error", "Failed to add address");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Get address list method

  var addressList = <AddressData>[].obs;

  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;

      String token = await SharedPre.getAccessToken();

      final response = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.GetAddress)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        final addressResponse = AddressResponse.fromJson(jsonData);

        addressList.value = addressResponse.data ?? [];
      } else {
        Get.snackbar("Faild", "Failed to fetch address");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  AddressData? getAddressById(String addressId) {
    try {
      return addressList.firstWhere((e) => e.id == addressId);
    } catch (e) {
      return null;
    }
  }

  // update Address api method -----

  Future<bool> updateAddressApi({
    required String addressId,
    required String label,
    required String street,
    required String area,
    required String city,
    required String state,
    required String zipCode,
    required String landmark,
    required bool isDefault,
  }) async {
    try {
      isLoading.value = true;

      String token = await SharedPre.getAccessToken();

      final body = {
        "label": label,
        "street": street,
        "area": area,
        "city": city,
        "state": state,
        "zipCode": zipCode,
        "lat": lat.value,
        "lng": lng.value,
        "landmark": landmark,
        "isDefault": isDefault,
      };

      final response = await http.put(
        Uri.parse("https://sog.bitmaxtest.com/api/v1/user/address/$addressId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("response $response");
        // 🔄 refresh address list
        await fetchAddresses();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Update Address Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // delecte address method api

  Future<bool> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;

      String token = await SharedPre.getAccessToken();

      final response = await http.delete(
        Uri.parse("https://sog.bitmaxtest.com/api/v1/user/address/$addressId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔄 local list update (fast UI)
        addressList.removeWhere((e) => e.id == addressId);

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Delete Address Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Banner controller method is here -----

  final PageController pageController = PageController();

  var banners = <BannerItem>[].obs;

  var currentIndex = 0.obs;

  Timer? _timer;

  Future<void> fetchBanners() async {
    try {
      isBannerLoading(true);

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final res = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.GetBanners)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        final response = BannerResponse.fromJson(decoded);

        banners.value = response.data ?? [];

        /// sort by order
        banners.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

        _startAutoScroll();
      }
    } catch (_) {
      banners.clear();
    } finally {
      isBannerLoading(false);
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();

    if (banners.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      currentIndex.value = (currentIndex.value + 1) % banners.length;

      pageController.animateToPage(
        currentIndex.value,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> refreshHome() async {
    try {
      isHomeRefreshing(true);

      await Future.wait([fetchBanners(), fetchCategories()]);
    } finally {
      isHomeRefreshing(false);
    }
  }

  // Popluar Dishes api method
}
