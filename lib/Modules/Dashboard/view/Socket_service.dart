import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:taste_of_bihar/utils/Sharedpre.dart';

class OrderSocketService {
  static IO.Socket? ordersocket;

  static Future<void> connect({
    required Function(dynamic data) onStatusUpdate,
    required Function(dynamic data) onTrackingInfo,
    required Function(dynamic data) onDeliveryAssigned,
    Function(dynamic data)? onDeliveryLocationUpdated,
  }) async {
    final token = await SharedPre.getAccessToken();
    if (token.isEmpty) return;

    ordersocket = IO.io(
      "https://sog.bitmaxtest.com/orders",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({"token": token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    ordersocket!.onConnect((_) {
      print("✅ ORDER SOCKET CONNECTED");

      ordersocket!.emit("JOIN_RESTAURANT_ROOM", {
        "restaurantId": "RESTO_123",
        "role": "USER",
        "source": "flutter_app",
      });
    });

    // ================= 🔔 NEW MENU ITEM =================
    ordersocket!.on("NEW_MENU_ITEM_ADDED", (data) {
      final item = data["item"];
      if (item == null) return;

      onStatusUpdate({
        "type": "NOTIFICATION",
        "notification": {
          "title": "New Item Added 🍽️",
          "message": "${item["name"]} • ₹${item["basePrice"]}",
          "data": {
            "type": "DAILY_MENU",
            "itemId": item["_id"],
            "name": item["name"],
            "price": item["basePrice"],
            "foodType": item["foodType"],
            "image": item["image"],
            "description": item["description"],
          },
        },
      });
    });

    // ================= 🔔 BROADCAST =================
    ordersocket!.on("NEW_BROADCAST", (data) {
      onStatusUpdate({"type": "NOTIFICATION", "notification": data});
    });

    // ================= STATUS EVENTS =================

    ordersocket!.on("ORDER_ACCEPTED", (data) {
      onStatusUpdate({
        "customOrderId": data["customOrderId"],
        "status": "ACCEPTED",
      });
    });

    ordersocket!.on("ORDER_PICKED_UP_BY_PARTNER", (data) {
      onStatusUpdate({
        "customOrderId": data["customOrderId"],
        "status": "OUT_FOR_DELIVERY",
      });
    });

    ordersocket!.on("ORDER_DELIVERED", (data) {
      onStatusUpdate({
        "customOrderId": data["customOrderId"],
        "status": "DELIVERED",
      });
    });

    // ================= ⭐ REVIEW ADDED =================
    ordersocket!.on("REVIEW_ADDED", (data) {
      print("⭐ REVIEW_ADDED => $data");

      onStatusUpdate({
        "type": "REVIEW_ADDED",
        "message": data["message"] ?? "Thank you for your review ⭐",
      });
    });

    // ================= 🔑 OTP =================
    ordersocket!.on("OTP_SENT", (data) {
      print("🔑 OTP_SENT => $data");

      onStatusUpdate({
        "customOrderId": data["customOrderId"],
        "otp": data["delivery"]?["otp"] ?? data["otp"],
        "order": data["order"], // 🔥 THIS LINE FIXES EVERYTHING
      });
    });

    // ================= TRACKING =================
    ordersocket!.on("ORDER_STATUS_UPDATE", (data) {
      onStatusUpdate({...data, "customOrderId": data["customOrderId"]});
    });

    ordersocket!.on("ORDER_TRACKING_INFO", onTrackingInfo);

    // ================= DELIVERY ASSIGNED =================
    ordersocket!.on("DELIVERY_ASSIGNED", (data) {
      onDeliveryAssigned(data);
    });

    // ================= 💸 REFUND =================
    ordersocket!.on("REFUND_STATUS_UPDATED", (data) {
      print("💸 REFUND_STATUS_UPDATED => $data");

      final orderId = data["order"]?["orderId"]; // ✅ ONLY ORDER ID

      if (orderId != null) {
        onStatusUpdate({
          "orderId": orderId, // ✅ NO customOrderId
          "refundStatus": data["order"]?["payment"]?["status"],
          "order": data["order"], // 🔥 FULL ORDER PASS KAR DO
        });
      }
    });

    // ================= 📍 LIVE LOCATION =================
    ordersocket!.on("DELIVERY_LOCATION_UPDATED", (data) {
      if (onDeliveryLocationUpdated != null) {
        onDeliveryLocationUpdated(data);
      }
    });

    ordersocket!.onError((e) {
      print("❌ SOCKET ERROR: $e");
    });
  }

  static void disconnect() {
    ordersocket?.disconnect();
    ordersocket?.dispose();
    ordersocket = null;
    print("🔌 ORDER SOCKET DISCONNECTED");
  }
}
