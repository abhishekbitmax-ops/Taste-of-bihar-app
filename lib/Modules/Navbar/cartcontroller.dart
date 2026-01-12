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
  var removingIndex = (-1).obs; // 👈 per-item delete loader

  final Authcontroller authCtrl = Get.put(Authcontroller());

  CartResponse? cartResponse;

  @override
  void onInit() {
    super.onInit();
    fetchCartApi();
    fetchOrderHistory(); // 👈 AUTO RESTORE CART ON APP START
  }

  var address = "".obs;
  var selectedAddress = "No address selected".obs;
  var selectedLat = "".obs;
  var savedAddresses = <Map<String, String>>[].obs;

  // CartController.dart
  var selectedPaymentMethod = "UPI".obs;

  final paymentMethods = ["UPI", "Cash on Delivery"];

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
    if (removingIndex.value != -1) return;

    try {
      removingIndex.value = index;

      String token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final cartItemId = cartResponse?.data?.cart?.items?[index].cartItemId;
      if (cartItemId == null) return;

      final url =
          "https://resto-grandma.onrender.com/api/v1/user/cart/$cartItemId/remove";

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        /// 🔥 OPTIMISTIC UI UPDATE
        cartItems.removeAt(index);
        cartItems.refresh();

        /// 🔥 IF LAST ITEM REMOVED → RESET CART
        if (cartItems.isEmpty) {
          clearCartAndReset(); // 👈 THIS TRIGGERS _emptyCartView()
          return;
        }

        /// Otherwise resync with backend
        await fetchCartApi();
      } else {
        Get.snackbar("Error", "Failed to remove item");
      }
    } catch (e) {
      Get.snackbar("Exception", "Something went wrong");
    } finally {
      removingIndex.value = -1;
    }
  }

  void clearCartAndReset() {
    cartItems.clear();
    cartResponse = null;
    grandTotal.value = 0.0;
    cartItems.refresh();
  }

  /// Fetch cart from API and sync
  Future<void> fetchCartApi() async {
    if (isLoading.value) return; // ✅ prevent overlap

    try {
      isLoading.value = true;

      String accessToken = await SharedPre.getAccessToken();
      if (accessToken.isEmpty) {
        clearCartAndReset();
        return;
      }

      final url = ApiEndpoint.getUrl(ApiEndpoint.getCart);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        clearCartAndReset();
        return;
      }

      final decoded = jsonDecode(response.body);

      cartResponse = CartResponse.fromJson(decoded);

      final cart = cartResponse?.data?.cart;

      // ✅ VERY IMPORTANT NULL CHECK
      if (cart == null || cart.items == null || cart.items!.isEmpty) {
        clearCartAndReset();
        return;
      }

      cartItems.clear();

      for (var item in cart.items!) {
        if (item.menuItemId == null) continue;

        cartItems.add({
          "cartItemId": item.cartItemId,
          "menuItemId": item.menuItemId,
          "name": item.name ?? "",
          "image": item.image ?? "",
          "price": "₹${item.basePrice}",
          "qty": item.quantity ?? 0,
          "itemTotal": item.itemTotal ?? 0,
          "specialInstructions": item.specialInstructions ?? "",
        });
      }

      grandTotal.value = cart.summary?.grandTotal ?? 0.0;
      cartItems.refresh();
    } catch (e, s) {
      debugPrint("FETCH CART ERROR: $e");
      debugPrint("STACKTRACE: $s");
      clearCartAndReset(); // ✅ NEVER crash UI
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- APPLY COUPON API ----------------
  Future<bool> applyCouponApi(String couponCode) async {
    try {
      isLoading.value = true;

      String token = await SharedPre.getAccessToken();
      if (token.isEmpty) {
        Get.snackbar("Error", "User not authenticated");
        return false;
      }

      final url = ApiEndpoint.getUrl(ApiEndpoint.ApplyCoupan);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"code": couponCode}),
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        // ✅ Refresh cart after coupon applied
        await fetchCartApi();

        Get.snackbar(
          "Coupon Applied",
          data["message"] ?? "Coupon applied successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          "Invalid Coupon",
          data["message"] ?? "Failed to apply coupon",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  var orders = <OrderModel>[].obs;

  Future<void> refreshOrders() async {
    await fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      final mobile = await SharedPre.getMobile();

      if (token.isEmpty || mobile.isEmpty) {
        orders.clear();
        return;
      }

      final url = ApiEndpoint.getUrl(ApiEndpoint.Orderhistorycard);

      final response = await http.get(
        Uri.parse("$url?mobile=$mobile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final res = OrderHistoryResponse.fromJson(decoded);

        orders.value = res.data ?? [];
      } else {
        orders.clear();
        Get.snackbar("Error", "Failed to fetch order history");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
