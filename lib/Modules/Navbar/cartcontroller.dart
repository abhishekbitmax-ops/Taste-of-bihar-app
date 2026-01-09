import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var grandTotal = 0.0.obs;
  var isLoading = false.obs;

  CartResponse? cartResponse;

  var address = "".obs;
  var selectedAddress = "No address selected".obs;
  var selectedLat = "".obs;
  var savedAddresses = <Map<String, String>>[].obs;

  void saveAddress(String addr) {
    address.value = addr;
  }

  /// API call to update quantity
  Future<void> updateQtyApi(int index, int newQty) async {
    try {
      isLoading.value = true;
      String token = await SharedPre.getAccessToken();
      final url = ApiEndpoint.getUrl(ApiEndpoint.Addtocart);

      final item = cartItems[index];
      final body = {
        "menuItemId": item["menuItemId"],
        "quantity": newQty,
        "specialInstructions": item["specialInstructions"] ?? "",
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCartApi(); // resync cart after update
      } else {
        Get.snackbar("Error", "Failed to update quantity");
      }
    } catch (e) {
      Get.snackbar("Exception", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  /// Increase qty using API
  /// Increase qty by 1 using API
  void increaseQty(int index) {
    int currentQty = cartItems[index]["qty"];
    updateQtyApi(index, currentQty + 1);
  }

  /// Decrease qty by 1 using API
  void decreaseQty(int index) {
    int currentQty = cartItems[index]["qty"];
    if (currentQty > 1) {
      updateQtyApi(index, currentQty - 1);
    }
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
