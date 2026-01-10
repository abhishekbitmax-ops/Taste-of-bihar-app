import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var grandTotal = 0.0.obs;
  var isLoading = false.obs;
  var updatingIndex = (-1).obs;
  final Authcontroller authCtrl = Get.put(Authcontroller());

  CartResponse? cartResponse;

  @override
  void onInit() {
    super.onInit();
    fetchCartApi(); // 👈 AUTO RESTORE CART ON APP START
  }

  var address = "".obs;
  var selectedAddress = "No address selected".obs;
  var selectedLat = "".obs;
  var savedAddresses = <Map<String, String>>[].obs;

  void saveAddress(String addr) {
    address.value = addr;
  }

  Future<void> increaseQty(int index) async {
    if (updatingIndex.value != -1) return;

    updatingIndex.value = index;
    final item = cartItems[index];

    final result = await authCtrl.addToCartApi(
      item["menuItemId"],
      1, // ✅ ONLY +1
      "",
    );

    if (result["success"] == true) {
      await fetchCartApi(); // backend is source of truth
    } else {
      Get.snackbar("Error", result["message"]);
    }

    updatingIndex.value = -1;
  }

  Future<void> decreaseQty(int index) async {
    if (updatingIndex.value != -1) return;

    final item = cartItems[index];
    final int qty = int.parse(item["qty"].toString());

    if (qty <= 1) return;

    updatingIndex.value = index;

    final result = await authCtrl.addToCartApi(
      item["menuItemId"],
      -1, // ✅ ONLY -1
      "",
    );

    if (result["success"] == true) {
      await fetchCartApi();
    } else {
      Get.snackbar("Error", result["message"]);
    }

    updatingIndex.value = -1;
  }

  // Remove item using API
  Future<void> removeItemApi(int index) async {
    try {
      isLoading.value = true;
      String token = await SharedPre.getAccessToken();

      // Get cartItemId from model
      final cartItemId = cartResponse?.data?.cart?.items?[index].cartItemId;
      if (cartItemId == null) {
        Get.snackbar("Error", "Cart Item ID not found");
        return;
      }

      final url =
          "https://resto-grandma.onrender.com/api/v1/user/cart/$cartItemId/remove";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({}), // body not needed
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCartApi(); // resync
      } else {
        Get.snackbar("Error", "Failed to remove item");
      }
    } catch (e) {
      Get.snackbar("Exception", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch cart from API and sync
  Future<void> fetchCartApi() async {
    try {
      isLoading.value = true;
      String accessToken = await SharedPre.getAccessToken();
      final url = ApiEndpoint.getUrl(ApiEndpoint.getCart);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        cartResponse = CartResponse.fromJson(jsonDecode(response.body));

        cartItems.clear();
        for (var item in cartResponse?.data?.cart?.items ?? []) {
          cartItems.add({
            "cartItemId": item.cartItemId,
            "menuItemId": item.menuItemId,
            "name": item.name,
            "image": item.image,
            "price": "₹${item.basePrice}",
            "qty": item.quantity,
            "itemTotal": item.itemTotal,
            "specialInstructions": item.specialInstructions,
            "cartItemId": item.cartItemId,
          });
        }

        /// Take grand total from API summary
        grandTotal.value = cartResponse?.data?.cart?.summary?.grandTotal ?? 0.0;
        cartItems.refresh();
      } else {
        Get.snackbar("Error", "Failed to fetch cart");
      }
    } catch (e) {
      Get.snackbar("Exception", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
