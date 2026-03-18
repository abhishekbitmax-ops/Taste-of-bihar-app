import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Dashboard/model/Dashboardmodel.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/Socket_service.dart';
import 'package:taste_of_bihar/Modules/ProfileSection/view/profilemodel.dart';
import 'package:taste_of_bihar/utils/Sharedpre.dart';
import 'package:taste_of_bihar/utils/api_endpoints.dart';
import 'package:taste_of_bihar/widgets/Globalnotifation.dart';
import 'package:taste_of_bihar/widgets/OrderConfrimscreen.dart';
import 'package:taste_of_bihar/widgets/Rating_and_review.dart';
import 'package:taste_of_bihar/widgets/RazorpayBottompay.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;
  var grandTotal = 0.0.obs;
  var isLoading = false.obs;
  var updatingIndex = (-1).obs;
  var selectedAddressId = "".obs;
  var applyingCouponCode = "".obs;
  var cartCategoryName = "".obs;
  var cartOrderStartTime = "".obs;
  var cartOrderEndTime = "".obs;
  var cartDeliveryStartTime = "".obs;
  var cartDeliveryEndTime = "".obs;

  // ================= LIVE MAP DATA =================
  var userLat = 0.0.obs;
  var userLng = 0.0.obs;
  var hasUserLocation = false.obs;

  var deliveryLat = 0.0.obs;
  var deliveryLng = 0.0.obs;
  var hasLiveLocation = false.obs;
  var roadDistance = 0.0.obs; // 🔥 Road distance in km (cached)
  var roadDistanceLoading = false.obs;
  var roadDirection = "".obs; // 🔥 Turn-by-turn direction
  var roadDuration = 0.obs;

  String? lastRestaurantId;
  String? lastFoodItemId;
  String? lastDeliveryPersonId; // already present

  final _pendingSocketEvents = <Map<String, dynamic>>[];
  late ConfettiController freeDeliveryConfetti;

  // 🔥 Duration in minutes

  // 🔥 Fetch road directions using Google Maps Directions API
  Future<void> fetchRoadDistance() async {
    if (roadDistanceLoading.value) return; // Prevent multiple calls
    if (userLat.value == 0 || deliveryLat.value == 0) return;

    try {
      roadDistanceLoading.value = true;

      const String googleMapsApiKey =
          "AIzaSyATQ_YYpnU1_tvoyRis0mmZPv8ifP2qbbM"; // ✅ Your API Key

      final String url =
          "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${userLat.value},${userLng.value}&"
          "destination=${deliveryLat.value},${deliveryLng.value}&"
          "mode=driving&"
          "key=$googleMapsApiKey";

      debugPrint("📡 Fetching directions from Google Maps API...");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["status"] == "OK" &&
            json["routes"] != null &&
            json["routes"].isNotEmpty) {
          final route = json["routes"][0];
          final leg = route["legs"][0];

          // 📍 Distance and Duration
          final distanceMeters = leg["distance"]["value"]; // in meters
          final durationSeconds = leg["duration"]["value"]; // in seconds

          roadDistance.value = distanceMeters / 1000; // Convert to km
          roadDuration.value = (durationSeconds / 60)
              .toInt(); // Convert to minutes

          // 🎯 First direction instruction
          if (leg["steps"] != null && leg["steps"].isNotEmpty) {
            final firstStep = leg["steps"][0];
            String instruction =
                firstStep["html_instructions"] ?? "Head towards destination";

            // Remove HTML tags
            instruction = instruction
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .replaceAll("&quot;", '"')
                .replaceAll("&amp;", "&")
                .replaceAll("&deg;", "°");

            roadDirection.value = instruction;

            debugPrint(
              "✅ Road Distance: ${roadDistance.value.toStringAsFixed(2)} km | Duration: ${roadDuration.value} min",
            );
            debugPrint("🎯 Direction: $instruction");
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching road distance: $e");
      roadDistance.value = 0;
    } finally {
      roadDistanceLoading.value = false;
    }
  }

  void handleDeliveryLocation(dynamic data) {
    if (data == null) return;

    try {
      /// ================= RIDER LOCATION (ALWAYS FROM TOP LEVEL) =================
      final rLat = data["lat"];
      final rLng = data["lng"] ?? data["lon"];

      if (rLat != null && rLng != null) {
        deliveryLat.value = (rLat as num).toDouble();
        deliveryLng.value = (rLng as num).toDouble();
        hasLiveLocation.value = true;

        debugPrint(
          "✅ Rider Location Set: ${deliveryLat.value}, ${deliveryLng.value}",
        );
      }

      /// ================= USER LOCATION (ONLY FROM deliveryAddress) =================
      final order = data["order"];
      final address = order?["deliveryAddress"];

      final uLat = address?["lat"];
      final uLng = address?["lng"];

      if (uLat != null && uLng != null) {
        userLat.value = (uLat as num).toDouble();
        userLng.value = (uLng as num).toDouble();
        hasUserLocation.value = true;

        debugPrint(
          "✅ User Location Set (deliveryAddress): "
          "${userLat.value}, ${userLng.value}",
        );
      }

      /// ================= FETCH ROAD ONCE =================
      if (hasUserLocation.value &&
          hasLiveLocation.value &&
          roadDistance.value == 0) {
        fetchRoadDistance();
      }

      debugPrint(
        "📍 UPDATED → Rider: ${deliveryLat.value},${deliveryLng.value} | "
        "User: ${userLat.value},${userLng.value}",
      );
    } catch (e, s) {
      debugPrint("❌ handleDeliveryLocation ERROR => $e");
      debugPrint("STACK => $s");
    }
  }

  var removingIndex = (-1).obs; // 👈 per-item delete loader

  final Authcontroller authCtrl = Get.put(Authcontroller());

  CartResponse? cartResponse;
  void clearCartAfterOrder() {
    cartItems.clear();
    cartResponse = null;
    grandTotal.value = 0.0;
    applyingCouponCode.value = "";
    selectedAddressId.value = "";
    clearSavedCartTiming();
    cartItems.refresh();
  }

  @override
  void onInit() {
    super.onInit();

    // 🛒 CART & USER DATA
    fetchCartApi();
    fetchNotifications();
    fetchOrderHistory();
    restoreSelectedAddress();
    fetchAvailableCoupons(); // 👈 AUTO RESTORE CART ON APP START

    // 🔥 SOCKET (LIVE TRACKING / STATUS)
    initOrderSocket();

    // 💣 FREE DELIVERY CONFETTI INIT
    freeDeliveryConfetti = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    freeDeliveryConfetti.dispose();
    super.onClose();
  }

  Future<void> restoreSelectedAddress() async {
    final savedId = await SharedPre.getSelectedAddressId();
    if (savedId.isEmpty) return;

    selectedAddressId.value = savedId;

    final authCtrl = Get.find<Authcontroller>();

    if (authCtrl.addressList.isEmpty) {
      await authCtrl.fetchAddresses();
    }

    final adr = authCtrl.getAddressById(savedId);
    if (adr != null) {
      selectedAddress.value = "${adr.street}, ${adr.area}, ${adr.city}";
    }

    // 🔥 ALSO RESTORE DELIVERY CHARGE
    if (cartResponse != null) {
      await selectAddressAndUpdateBill(savedId);
    }
  }

  var address = "".obs;
  var selectedAddress = "No address selected".obs;
  var selectedLat = "".obs;
  var savedAddresses = <Map<String, String>>[].obs;

  // CartController.dart
  var selectedPaymentMethod = "ONLINE".obs;

  final paymentMethods = ["ONLINE", "COD"];

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
          "https://bihar-taste.bitmaxtest.com/api/v1/user/cart/$cartItemId/remove";

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
    clearSavedCartTiming();
    cartItems.refresh();
  }

  Future<void> restoreCartTiming() async {
    final timing = await SharedPre.getCartTiming();
    cartCategoryName.value = timing["categoryName"] ?? "";
    cartOrderStartTime.value = timing["orderStartTime"] ?? "";
    cartOrderEndTime.value = timing["orderEndTime"] ?? "";
    cartDeliveryStartTime.value = timing["deliveryStartTime"] ?? "";
    cartDeliveryEndTime.value = timing["deliveryEndTime"] ?? "";
  }

  Future<void> clearSavedCartTiming() async {
    cartCategoryName.value = "";
    cartOrderStartTime.value = "";
    cartOrderEndTime.value = "";
    cartDeliveryStartTime.value = "";
    cartDeliveryEndTime.value = "";
    await SharedPre.clearCartTiming();
  }

  int? _timeToMinutes(String value) {
    final parts = value.split(":");
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return (hour * 60) + minute;
  }

  String _formatTime(String value) {
    final totalMinutes = _timeToMinutes(value);
    if (totalMinutes == null) return value;

    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    final suffix = hour >= 12 ? "PM" : "AM";
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    return "$normalizedHour:${minute.toString().padLeft(2, '0')} $suffix";
  }

  bool get canPlaceOrderNow {
    if (cartOrderStartTime.value.isEmpty || cartOrderEndTime.value.isEmpty) {
      return true;
    }

    final start = _timeToMinutes(cartOrderStartTime.value);
    final end = _timeToMinutes(cartOrderEndTime.value);
    if (start == null || end == null) return true;

    final now = DateTime.now();
    final current = (now.hour * 60) + now.minute;

    if (start == end) return true;
    if (end > start) {
      return current >= start && current <= end;
    }

    return current >= start || current <= end;
  }

  String get placeOrderTimingMessage {
    final label = cartCategoryName.value.isNotEmpty
        ? cartCategoryName.value
        : "This menu";

    if (cartOrderStartTime.value.isEmpty || cartOrderEndTime.value.isEmpty) {
      return "$label order timing is not available right now.";
    }

    return "$label orders are available between "
        "${_formatTime(cartOrderStartTime.value)} and "
        "${_formatTime(cartOrderEndTime.value)}.";
  }

  /// Fetch cart from API and sync
  Future<void> fetchCartApi() async {
    if (isLoading.value) return; // ✅ prevent overlap

    try {
      isLoading.value = true;

      final accessToken = await SharedPre.getAccessToken();
      if (accessToken.isEmpty) {
        clearCartAndReset();
        return;
      }

      await restoreCartTiming();

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

      // ❌ EMPTY CART
      if (cart == null || cart.items == null || cart.items!.isEmpty) {
        clearCartAndReset();
        return;
      }

      // ================= CACHE IDS =================
      lastRestaurantId = cart.restaurant?.id;
      lastFoodItemId = cart.items!.first.menuItemId;

      debugPrint("🍽️ Cached restaurantId => $lastRestaurantId");
      debugPrint("🍔 Cached foodItemId => $lastFoodItemId");
      // ============================================

      // ================= CART ITEMS =================
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

      cartItems.refresh();

      // ================= GRAND TOTAL (TEMP) =================
      grandTotal.value = cart.summary?.grandTotal ?? 0.0;

      // ================= 🔥 RE-APPLY SAVED ADDRESS =================
      final savedAddressId = await SharedPre.getSelectedAddressId();

      if (savedAddressId.isNotEmpty) {
        debugPrint("♻️ Re-applying addressId => $savedAddressId");

        /// 🚨 IMPORTANT SAFETY:
        /// - isLoading false kar ke call
        /// - warna API block ho jayegi
        isLoading.value = false;

        await selectAddressAndUpdateBill(savedAddressId);
      }
    } catch (e, s) {
      debugPrint("❌ FETCH CART ERROR => $e");
      debugPrint("📋 STACKTRACE => $s");
      clearCartAndReset();
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
          "Accept": "application/json",
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

      final url = ApiEndpoint.getOrderTrackingUrl(orderId);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        debugPrint("📡 FETCH ORDER TRACKING RESPONSE => $decoded");

        /// ✅ DIRECT PARSE (API HAS NO success/data WRAPPER)
        final trackingResponse = OrderTrackingResponse.fromJson(decoded);
        final trackingData = trackingResponse.data;

        // 🔥 SET THE ORDER WITH ALL DATA
        if (trackingData != null) {
          order.value = trackingData;
          order.refresh();
        } else {
          Get.snackbar("Error", "Order tracking data not found");
        }
      } else {
        debugPrint("❌ API Error: ${response.statusCode}");
        debugPrint("❌ ORDER TRACKING BODY: ${response.body}");
        Get.snackbar("Error", "Failed to fetch order tracking");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ FETCH ORDER TRACKING ERROR => $e");
      debugPrint("📋 StackTrace: $stackTrace");
      Get.snackbar("Exception", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //  Rating and review api method

  Future<bool> submitRating({
    required int rating,
    required String comment,
    required String restaurantId,
    required String orderId,
    required String deliveryPersonId,
    required String foodItemId,
  }) async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();

      final body = {
        "restaurant": restaurantId,
        "order": orderId,
        "deliveryPerson": deliveryPersonId,
        "foodItem": foodItemId,
        "rating": {"overall": rating},
        "comment": comment,
      };

      final response = await http.post(
        Uri.parse(ApiEndpoint.getUrl2(ApiEndpoint.Ratingreview)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("⭐ Rating API success");
        return true; // 👈 IMPORTANT
      }

      return false;
    } catch (e) {
      return false;
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

  String getFirstFoodItemIdFromCart() {
    final items = cartResponse?.data?.cart?.items;
    if (items == null || items.isEmpty) return "";
    return items.first.menuItemId ?? "";
  }

  // ----------------------------------

  Future<void> handleSocketStatusUpdate(dynamic data) async {
    if (data == null) return;

    // ================= 🔔 SOCKET NOTIFICATION =================
    if (data is Map && data["type"] == "NOTIFICATION") {
      final raw = data["notification"];
      final payload = raw?["data"];

      debugPrint("🔔 SOCKET NOTIFICATION => $raw");

      final socketNotification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: raw?["title"] ?? "New Notification",
        message: raw?["message"],
        type: payload?["type"],
        isRead: false,
        createdAt: DateTime.now(),
        data: payload != null
            ? NotificationPayload(
                type: payload["type"],
                itemId: payload["itemId"],
                name: payload["name"],
                price: payload["price"],
                foodType: payload["foodType"],
                image: payload["image"],
                description: payload["description"],
                otp: payload["otp"],
                orderId: payload["orderId"],
                orderCustomId: payload["orderCustomId"],
              )
            : null,
      );

      notifications.insert(0, socketNotification);
      notifications.refresh();

      String toastMessage = raw?["message"] ?? "";
      if (payload?["type"] == "DELIVERY_OTP") {
        toastMessage = "Your delivery OTP is ${payload["otp"]}";
      }

      GlobalNotificationService.show(
        title: raw?["title"] ?? "New Notification",
        message: toastMessage,
      );

      return;
    }

    // ================= ⭐ REVIEW ADDED =================
    if (data is Map && data["type"] == "REVIEW_ADDED") {
      GlobalNotificationService.show(
        title: "Review Submitted ⭐",
        message: data["message"] ?? "Thanks for sharing your feedback",
      );
      return;
    }

    // ================= 🔑 OTP EVENT (HANDLE FIRST — NO ID CHECK) =================
    if (data is Map) {
      // 🔑 OTP (support both keys)
      final otp = data["deliveryOTP"] ?? data["otp"];

      // ================= 🚴 DELIVERY PERSON ID (ROBUST) =================

      String? partnerId;

      // CASE 1️⃣: order.delivery.partner  (preferred – full payload)
      final orderMap = data["order"];
      if (orderMap is Map) {
        final delivery = orderMap["delivery"];
        if (delivery is Map && delivery["partner"] != null) {
          partnerId = delivery["partner"].toString();
        }
      }

      // CASE 2️⃣: direct delivery.partner (fallback – flat payload)
      if (partnerId == null && data["delivery"] is Map) {
        final delivery = data["delivery"];
        if (delivery["partner"] != null) {
          partnerId = delivery["partner"].toString();
        }
      }

      // SAVE IF FOUND
      if (partnerId != null && partnerId.isNotEmpty) {
        lastDeliveryPersonId = partnerId;
      }

      // ================================================================

      if (otp != null && otp.toString().isNotEmpty) {
        debugPrint("🔑 OTP RECEIVED FROM SOCKET => $otp");
        debugPrint("🚴 DeliveryPersonId => $lastDeliveryPersonId");

        if (order.value != null) {
          order.value = order.value!.copyWith(
            deliveryOTP: otp.toString(),
            delivery:
                order.value!.delivery ??
                Delivery(
                  otp: otp.toString(),
                  partner: null, // 👈 ID already cached separately
                ),
          );
          order.refresh();
        }

        GlobalNotificationService.show(
          title: "Delivery OTP",
          message: "Your delivery OTP is $otp",
        );

        return;
      }
    }

    // ================= 💸 REFUND STATUS (SINGLE SOURCE OF TRUTH) =================
    if (data is Map && data["order"] != null) {
      final orderId = data["order"]["orderId"];
      final paymentStatus = data["order"]["payment"]?["status"];

      debugPrint(
        "💸 REFUND SOCKET HIT → orderId=$orderId | status=$paymentStatus",
      );

      if (orderId != null) {
        // 🔥 FORCE API REFRESH → UI AUTO UPDATE
        await fetchOrderTracking(orderId);
        await fetchRefund(orderId);
      }

      return; // ⛔ STOP EVERYTHING ELSE
    }

    // ================= ORDER STATUS EVENTS (NEED ID MATCH) =================
    if (order.value == null || data is! Map) return;

    debugPrint("📡 SOCKET STATUS UPDATE RECEIVED => $data");

    final socketOrderId = data["customOrderId"] ?? data["orderId"];
    if (socketOrderId == null) return;

    if (socketOrderId != order.value!.orderId &&
        socketOrderId != order.value!.id) {
      return;
    }

    // ================= STATUS UPDATE =================
    final status = data["status"];
    if (status == null || status.toString().isEmpty) return;

    final normalized = status.toString().toUpperCase().trim();
    order.value = order.value!.copyWith(status: normalized);

    if (normalized == "DELIVERED") {
      fetchOrderHistory();
    }

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

        Future.delayed(const Duration(seconds: 2), () {
          if (Get.context != null) {
            Get.dialog(
              RatingDialog(
                restaurantId: lastRestaurantId ?? "",
                orderId: order.value?.orderId ?? "",
                deliveryPersonId: lastDeliveryPersonId ?? "",
                foodItemId: lastFoodItemId ?? "",
              ),
              barrierDismissible: false,
            );
          }
        });

        break;
    }
  }

  // 🔥 HANDLE DETAILED TRACKING INFO

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
      order.refresh(); // 🔥 FORCE UI REFRESH
    }
  }

  // 🔥 HANDLE DELIVERY ASSIGNED WITH PARTNER DATA
  void handleDeliveryAssigned(dynamic data) {
    if (order.value == null || data == null) return;

    try {
      if (data is Map<String, dynamic>) {
        // 🔥 Normalize socket payload → API-like structure
        final delivery = Delivery(
          otp: order.value?.deliveryOTP,
          assignedAt: data['assignedAt'],
          partner: DeliveryPartner(
            name: data['deliveryPartner']?['name'],
            phone: data['deliveryPartner']?['phone'],
            vehicle: Vehicle(type: data['deliveryPartner']?['vehicleType']),
          ),
        );

        final old = order.value!;

        /// 🔥 CREATE BRAND NEW ORDER OBJECT (VERY IMPORTANT)
        order.value = OrderTrackingData(
          orderId: old.orderId,
          id: old.id,
          status: old.status,
          deliveryOTP: old.deliveryOTP,
          timeline: old.timeline,
          estimatedDelivery: old.estimatedDelivery,
          restaurant: old.restaurant,
          deliveryAddress: old.deliveryAddress,
          items: old.items,
          price: old.price,
          payment: old.payment,
          delivery: delivery, // ✅ FIXED
          createdAt: old.createdAt,
          canCancel: old.canCancel,
        );

        order.refresh(); // 🔥 FORCE UI REBUILD

        GlobalNotificationService.show(
          title: "Delivery Assigned",
          message: "Your order has been assigned to a rider 🚴",
        );
      }
    } catch (e, s) {
      debugPrint("❌ DELIVERY_ASSIGNED ERROR => $e");
      debugPrint("$s");
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
      onDeliveryAssigned: handleDeliveryAssigned, // 🔥 Use new handler
      onDeliveryLocationUpdated: handleDeliveryLocation,
    );
  }

  // Cancel order api method ------

  Future<bool> cancelOrderApi({
    required String orderId,
    required double amount,
    required String paymentMethod, // COD / ONLINE
    String? paymentId,
  }) async {
    try {
      final token = await SharedPre.getAccessToken();

      final url = Uri.parse(
        "https://resto-grandma.onrender.com/api/v1/user/order/$orderId/cancel",
      );

      /// 🔥 BUILD PAYMENT OBJECT AS BACKEND EXPECTS
      final Map<String, dynamic> payment = {};

      if (paymentMethod.toUpperCase() == "COD") {
        payment["type"] = "COD";
        payment["method"] = "CASH"; //  VALID ENUM
      } else {
        payment["type"] = "ONLINE";
        payment["method"] = "RAZORPAY"; //  VALID ENUM

        if (paymentId != null && paymentId.isNotEmpty) {
          payment["paymentId"] = paymentId;
        }
      }

      final body = {
        "amount": amount,
        "reason": "Order cancelled by user",
        "payment": payment,
      };

      debugPrint("CANCEL ORDER BODY => $body");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      debugPrint(" CANCEL ORDER RES => ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return true;
      } else {
        throw data["message"] ?? "Failed to cancel order";
      }
    } catch (e) {
      debugPrint(" CANCEL ORDER ERROR => $e");
      rethrow;
    }
  }

  Future<void> cancelOrder({
    required String orderId,
    required double amount,
    required String paymentMethod, // COD / ONLINE
    String? paymentId,
  }) async {
    try {
      isLoading.value = true;

      final success = await cancelOrderApi(
        orderId: orderId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentId: paymentId,
      );

      if (success) {
        Get.snackbar(
          "Order Cancelled",
          "Your order has been cancelled successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await fetchRefund(orderId);

        // 🔥 Refresh tracking + history
        await fetchOrderTracking(orderId);
        await fetchOrderHistory();
      }
    } catch (e) {
      Get.snackbar(
        "Cancel Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refund payment method -----

  var refund = Rx<RefundData?>(null);

  Future<void> fetchRefund(String orderId) async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final url =
          "https://resto-grandma.onrender.com/api/v1/user/order/$orderId/refund";

      final res = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        final response = RefundResponse.fromJson(decoded);
        refund.value = response.data;
        refund.refresh();
      } else {
        refund.value = null;
      }
    } catch (e) {
      refund.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    refund.value = null;
  }

  // notifaction api method -----

  var notifications = <AppNotification>[].obs;

  int get unreadCount {
    return notifications.where((n) => n.isRead != true).length;
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final url = ApiEndpoint.getUrl(ApiEndpoint.Getnotifaction);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final res = NotificationResponse.fromJson(decoded);
        notifications.value = res.data ?? [];
      } else {
        notifications.clear();
      }
    } catch (e) {
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // mark to read api method ------

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return;

      final url = Uri.parse(
        "https://resto-grandma.onrender.com/api/v1/user/notifications/$notificationId/read",
      );

      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔥 LOCAL LIST UPDATE (NO EXTRA API CALL)
        final index = notifications.indexWhere((n) => n.id == notificationId);

        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          notifications.refresh();
        }
      }
    } catch (e) {
      debugPrint("❌ MARK READ ERROR => $e");
    }
  }

  // --- Address selection for cart ---

  Future<bool> selectAddressAndUpdateBill(String addressId) async {
    try {
      isLoading.value = true;

      final token = await SharedPre.getAccessToken();
      if (token.isEmpty) return false;

      final url = ApiEndpoint.getUrl(ApiEndpoint.SelectAddress);

      final res = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"addressId": addressId}),
      );

      final decoded = jsonDecode(res.body);
      debugPrint("📍 SELECT ADDRESS RES => $decoded");

      // ❌ DELIVERY NOT AVAILABLE
      if (decoded["success"] != true) {
        Get.snackbar(
          "Delivery Unavailable",
          decoded["message"] ??
              "Delivery is not available for the selected address",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // ✅ SUCCESS CASE
      final data = decoded["data"];
      final summary = cartResponse?.data?.cart?.summary;

      if (summary != null) {
        cartResponse!.data!.cart!.summary = summary.copyWith(
          subtotal: data["subtotal"],
          tax: (data["tax"] as num).toDouble(),
          deliveryCharge: data["deliveryCharge"],
          grandTotal: (data["grandTotal"] as num).toDouble(),
        );
      }

      grandTotal.value = (data["grandTotal"] as num).toDouble();
      if (data["deliveryCharge"] == 0) {
        freeDeliveryConfetti.play(); // 💣 BOOM
      }

      cartItems.refresh();

      return true;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong while checking delivery",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
