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

  var address = "".obs;
  var selectedAddress = "No address selected".obs;
  var selectedLat = "".obs;
  var savedAddresses = <Map<String, String>>[].obs;

  void saveAddress(String addr) {
    address.value = addr;
  }

  /// Bill subtotal calculation (price * qty)
  int get subtotal => cartItems.fold(0, (sum, item) {
    if (item["itemTotal"] is int) {
      return sum + (item["itemTotal"] as int); // 👈 direct use
    }
    int price =
        int.tryParse(item["price"].toString().replaceAll("₹", "").trim()) ?? 0;
    int quantity = item["qty"] is int
        ? item["qty"]
        : int.tryParse(item["qty"].toString()) ?? 1;
    return sum + (price * quantity);
  });

  void increaseQty(int i) {
    int price =
        int.tryParse(
          cartItems[i]["price"].toString().replaceAll("₹", "").trim(),
        ) ??
        0;
    int qty = cartItems[i]["qty"] + 1; // ensure qty key exists
    cartItems[i]["qty"] = qty;
    cartItems[i]["itemTotal"] = price * qty;
    grandTotal.value = subtotal.toDouble();
    cartItems.refresh();
  }

  void decreaseQty(int i) {
    int price =
        int.tryParse(
          cartItems[i]["price"].toString().replaceAll("₹", "").trim(),
        ) ??
        0;
    int qty = cartItems[i]["qty"];
    if (qty > 1) {
      qty -= 1;
      cartItems[i]["qty"] = qty;
      cartItems[i]["itemTotal"] = price * qty;
      grandTotal.value = subtotal.toDouble();
      cartItems.refresh();
    }
  }

  void removeItem(int i) {
    cartItems.removeAt(i);
    grandTotal.value = subtotal.toDouble();
    cartItems.refresh();
  }

  /// Add to cart locally from BottomSheet
  void addToCart(Map<String, String> product, int qty) {
    int price = int.tryParse(product["price"]!.replaceAll("₹", "").trim()) ?? 0;
    int itemTotal = price * qty; // 👈 calculate locally

    cartItems.add({
      "id": product["id"] ?? "",
      "name": product["name"] ?? "",
      "image": (product["image"] ?? "").isEmpty
          ? "assets/images/popular.png"
          : product["image"],
      "price": "₹$price",
      "qty": qty,
      "itemTotal": itemTotal, // 👈 store item total
    });

    // Update grand total
    grandTotal.value = subtotal.toDouble();
    cartItems.refresh();
  }

  /// Total items count for bar
  int get totalCount => cartItems.fold(0, (sum, item) {
    int quantity = item["qty"] is int
        ? item["qty"]
        : int.tryParse(item["qty"].toString()) ?? 1;

    return sum + quantity;
  });

  var isLoading = false.obs;
  CartResponse? cartResponse;

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

        // Sync items
        cartItems.clear();
        for (var item in cartResponse?.data?.cart?.items ?? []) {
          int qty = item.quantity ?? 1;
          int price = item.basePrice ?? 0;
          int total =
              item.itemTotal ??
              (price * qty); // 👈 prefer API total, else calculate

          cartItems.add({
            "menuItemId": item.menuItemId,
            "name": item.name,
            "price": "₹$price",
            "qty": qty, // 👈 FIXED
            "image": item.image,
            "itemTotal": total,
          });
        }

        // Update grand total from API
        final summary = cartResponse?.data?.cart?.summary;
        grandTotal.value = summary?.grandTotal ?? subtotal.toDouble();

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
