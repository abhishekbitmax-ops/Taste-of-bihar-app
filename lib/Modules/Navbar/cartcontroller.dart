import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/model/Dashboardmodel.dart';
import 'package:restro_app/Modules/Dashboard/view/Socket_service.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:restro_app/widgets/Globalnotifation.dart';
import 'package:restro_app/widgets/OrderConfrimscreen.dart';
import 'package:restro_app/widgets/RazorpayBottompay.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var grandTotal = 0.0.obs;
  var isLoading = false.obs;
  var updatingIndex = (-1).obs;
  var selectedAddressId = "".obs;
  var applyingCouponCode = "".obs;

  var removingIndex = (-1).obs; // 👈 per-item delete loader

  final Authcontroller authCtrl = Get.put(Authcontroller());

  CartResponse? cartResponse;
  void clearCartAfterOrder() {
    cartItems.clear();
    cartResponse = null;
    grandTotal.value = 0.0;
    applyingCouponCode.value = "";
    selectedAddressId.value = "";
    cartItems.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCartApi();
    fetchOrderHistory();

    fetchAvailableCoupons(); // 👈 AUTO RESTORE CART ON APP START
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
          "https://sog.bitmaxtest.com/api/v1/user/cart/$cartItemId/remove";

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
    if (applyingCouponCode.value.isNotEmpty) return false;

    try {
      applyingCouponCode.value = couponCode;

      final token = await SharedPre.getAccessToken();
      final res = await http.post(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.ApplyCoupan)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"code": couponCode}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        await fetchCartApi();
        Get.snackbar("Coupon Applied", data["message"]);
        return true;
      } else {
        Get.snackbar("Invalid Coupon", data["message"]);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      applyingCouponCode.value = "";
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrderHistory();
  }

  var orders = <OrderData>[].obs;
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

        final list = res.data ?? [];

        /// 🔥 SORT BY CREATED DATE (LATEST FIRST)
        list.sort((a, b) {
          final da = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
          final db = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
          return db.compareTo(da);
        });

        orders.value = list;
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

  var isPlacingOrder = false.obs;
  var orderId = "".obs;
  var razorpayOrderId = "".obs;
  Map<String, dynamic>? lastPlacedOrder;

  /// =========================
  /// PLACE ORDER API
  /// =========================
  Future<void> placeOrder({
    required String addressId,
    required String paymentMethod,
  }) async {
    try {
      isPlacingOrder(true);

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) {
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      final cart = cartResponse?.data?.cart;

      if (cart == null || cart.items == null || cart.items!.isEmpty) {
        Get.snackbar("Error", "Cart is empty");
        return;
      }

      // 🔥 BUILD ITEMS ARRAY
      final List<Map<String, dynamic>> itemsPayload = cart.items!
          .where((e) => e.menuItemId != null && e.quantity != null)
          .map((e) => {"itemId": e.menuItemId, "quantity": e.quantity})
          .toList();

      final body = {
        "cartId": cart.id,
        "items": itemsPayload,
        "addressId": addressId,
        "paymentMethod": paymentMethod, // UPI / COD
      };

      debugPrint("🛒 PLACE ORDER BODY => $body");

      final res = await http.post(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.Orderplace)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);
      debugPrint("📦 PLACE ORDER RESPONSE => $data");
      if (res.statusCode == 200 || res.statusCode == 201) {
        lastPlacedOrder = data["data"]; // 👈 🔥 MOST IMPORTANT

        orderId.value = data["data"]["orderId"] ?? "";

        if (paymentMethod == "COD") {
          // ✅ COD SAME
          clearCartAfterOrder();
          Get.offAll(() => OrderConfirmationScreen(), arguments: data["data"]);
        } else {
          // 🔥 UPI → DO NOT CLEAR CART HERE
          razorpayOrderId.value = data["data"]["razorpay"]?["orderId"] ?? "";
          final int amountInPaise = (data["data"]["razorpay"]?["amount"] ?? 0)
              .toInt();

          openRazorpaySheet(amount: amountInPaise / 100);
        }
      } else {
        Get.snackbar("Error", data["message"] ?? "Order failed");
      }
    } catch (e, s) {
      debugPrint("❌ PLACE ORDER ERROR => $e");
      debugPrint("STACKTRACE => $s");
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isPlacingOrder(false);
    }
  }

  /// =========================
  /// OPEN PAYMENT SHEET
  /// =========================
  void openRazorpaySheet({required num amount}) {
    Get.dialog(PaymentBottomSheet(amount: amount), barrierDismissible: false);
  }

  /// =========================
  /// VERIFY PAYMENT API
  /// =========================
  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) {
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      final body = {
        "razorpay_order_id": razorpayOrderId, // order_S3...
        "razorpay_payment_id": razorpayPaymentId, // pay_...
        "razorpay_signature": razorpaySignature, // generated by Razorpay
        "orderId": orderId.value, // ORD-... (DB order)
      };

      debugPrint("🔐 VERIFY PAYMENT BODY => $body");

      final res = await http.post(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.PaymentVerify)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);
      debugPrint("✅ VERIFY PAYMENT RESPONSE => $data");

      if (res.statusCode == 200 && data["success"] == true) {
        clearCartAfterOrder();

        Get.offAll(
          () => OrderConfirmationScreen(),
          arguments: {
            ...?lastPlacedOrder, // 🔥 FULL ORDER DATA
            "payment": {
              ...?lastPlacedOrder?["payment"],
              "status": "PAID", // 🔥 Force update
            },
          },
        );
      } else {
        Get.snackbar(
          "Payment Failed",
          data["message"] ?? "Verification failed",
        );
      }
    } catch (e, s) {
      debugPrint("❌ VERIFY PAYMENT ERROR => $e");
      debugPrint("STACKTRACE => $s");
      Get.snackbar("Error", "Something went wrong during verification");
    }
  }

  // order tracking api method

  final Rx<OrderTrackingData?> order = Rx<OrderTrackingData?>(null);

  Future<void> fetchOrderTracking(String orderId) async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) {
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      final url = "https://sog.bitmaxtest.com/api/v1/user/order/$orderId/track";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final res = OrderTrackingResponse.fromJson(decoded);

        order.value = res.data;
      } else {
        Get.snackbar("Error", "Failed to fetch order tracking");
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  var popularDishes = <ProductData>[].obs;

  Future<void> fetchPopularDishes() async {
    if (popularDishes.isNotEmpty) return;
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final res = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.PopluarDishs)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        final response = ProductResponse.fromJson(decoded);

        popularDishes.value = response.data ?? [];
      }
    } catch (e) {
      print("POPULAR DISH ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Get all Applycoupan api method
  var availableCoupons = <Coupon>[].obs;

  Future<void> fetchAvailableCoupons() async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final res = await http.get(
        Uri.parse(ApiEndpoint.getUrl(ApiEndpoint.GetCoupancode)),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);

        final couponResponse = CouponResponse.fromJson(decoded);

        availableCoupons.value = couponResponse.data ?? [];
      } else {
        availableCoupons.clear();
      }
    } catch (e) {
      debugPrint("❌ FETCH COUPONS ERROR => $e");
      availableCoupons.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------------

  void handleSocketStatusUpdate(dynamic data) {
    if (order.value == null || data == null) return;

    String? status;
    String? otp;

    if (data is Map) {
      status = data["status"];
      otp = data["otp"];
    } else if (data is String) {
      status = data;
    }

    /// 🔥 OTP UPDATE (STATUS BAR NOTIFICATION)
    if (otp != null && otp.isNotEmpty) {
      order.value = order.value!.copyWith(delivery: Delivery(otp: otp));

      GlobalNotificationService.show(
        title: "Delivery OTP",
        message: "Your delivery OTP is $otp",
      );
      return;
    }

    if (status == null || status.isEmpty) return;

    final normalized = status.toUpperCase().trim();

    /// 🔥 UPDATE STATUS (AUTO UI + TIMELINE)
    order.value = order.value!.copyWith(status: normalized);

    if (normalized == "DELIVERED") {
      fetchOrderHistory(); // 🔥 refresh list automatically
    }

    /// 🔔 NOTIFICATIONS
    switch (normalized) {
      case "ACCEPTED":
        GlobalNotificationService.show(
          title: "Order Accepted",
          message: "Restaurant has accepted your order 🍽️",
        );
        break;

      case "OUT_FOR_DELIVERY":
        GlobalNotificationService.show(
          title: "Out for Delivery",
          message: "Your order is on the way 🚴",
        );
        break;

      case "DELIVERED":
        GlobalNotificationService.show(
          title: "Order Delivered",
          message: "Enjoy your meal 🍽️",
        );
        break;
    }
  }

  void handleSocketTrackingInfo(dynamic data) {
    if (order.value == null || data == null) return;

    // 🔥 CASE 1: Only status string
    if (data is String) {
      order.value = order.value!.copyWith(status: data);
      return;
    }

    // 🔥 CASE 2: Full object
    if (data is Map<String, dynamic>) {
      order.value = OrderTrackingData.fromSocket(old: order.value!, json: data);
    }
  }

  // socket connect 

  /// =========================
/// INIT ORDER SOCKET (LOGIN / REGISTER KE BAAD CALL KARNA)
/// =========================
Future<void> initOrderSocket() async {
  await OrderSocketService.connect(
    onStatusUpdate: handleSocketStatusUpdate,
    onTrackingInfo: handleSocketTrackingInfo,
    onDeliveryAssigned: (data) {
      GlobalNotificationService.show(
        title: "Delivery Assigned",
        message: "Your order has been assigned to a rider 🚴",
      );
    },
  );
}

}
