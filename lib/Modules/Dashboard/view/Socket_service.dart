import 'package:restro_app/widgets/Globalnotifation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:restro_app/utils/Sharedpre.dart';

class OrderSocketService {
  static IO.Socket? ordersocket;

  static Future<void> connect({
    required Function(dynamic data) onStatusUpdate,
    required Function(dynamic data) onTrackingInfo,
    required Function(dynamic data) onDeliveryAssigned,
    Function(dynamic data)?
    onDeliveryLocationUpdated, // 👈 NEW OPTIONAL CALLBACK
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

      print("📤 JOIN_RESTAURANT_ROOM EMITTED");
    });

    // ================= STATUS EVENTS =================

    ordersocket!.on("ORDER_ACCEPTED", (data) {
      onStatusUpdate({"orderId": data["orderId"], "status": "ACCEPTED"});
    });

    ordersocket!.on("ORDER_PICKED_UP_BY_PARTNER", (data) {
      onStatusUpdate({
        "orderId": data["orderId"],
        "status": "OUT_FOR_DELIVERY",
      });
    });

    ordersocket!.on("ORDER_DELIVERED", (data) {
      onStatusUpdate({"orderId": data["orderId"], "status": "DELIVERED"});
    });

    ordersocket!.on("OTP_SENT", (data) {
      print("🔑 OTP_SENT EVENT RECEIVED => $data");
      final otp = data["otp"];
      final orderId = data["orderId"];
      print("📍 OTP: $otp | ORDER ID: $orderId");
      onStatusUpdate({"orderId": orderId, "otp": otp});
    });

    // ================= TRACKING EVENTS =================

    ordersocket!.on("ORDER_STATUS_UPDATE", onStatusUpdate);
    ordersocket!.on("ORDER_TRACKING_INFO", onTrackingInfo);

    ordersocket!.on("DELIVERY_ASSIGNED", (data) {
      print("👤 DELIVERY_ASSIGNED EVENT RECEIVED => $data");
      final delivery = data["delivery"];
      final partner = data["partner"];

      if (delivery != null) {
        print("📦 Delivery Data: $delivery");
      }
      if (partner != null) {
        print("👤 Partner Data: ${partner["name"]} | ${partner["phone"]}");
      }

      onDeliveryAssigned(data);
    });

    // ================= 🔥 NEW EVENT =================
    ordersocket!.on("DELIVERY_LOCATION_UPDATED", (data) {
      print("📍 DELIVERY_LOCATION_UPDATED => $data");

      if (onDeliveryLocationUpdated != null) {
        onDeliveryLocationUpdated(data);
      }
    });

    ordersocket!.on("CONNECTION_ESTABLISHED", (data) {
      print("🎉 ROOM JOINED: $data");
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
