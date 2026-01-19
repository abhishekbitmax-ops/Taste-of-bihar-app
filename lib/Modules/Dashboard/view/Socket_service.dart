import 'package:restro_app/widgets/Globalnotifation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:restro_app/utils/Sharedpre.dart';

class OrderSocketService {
  static IO.Socket? socket, ordersocket;

  static Future<void> connect({
    required Function(dynamic data) onStatusUpdate,
    required Function(dynamic data) onTrackingInfo,
    required Function(dynamic data) onDeliveryAssigned,
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

      // 🔥 EMIT AFTER CONNECT (THIS WAS MISSING)
      ordersocket!.emit("JOIN_RESTAURANT_ROOM", {
        "restaurantId": "RESTO_123",
        "role": "USER",
        "source": "flutter_app",
      });

      print("📤 JOIN_RESTAURANT_ROOM EMITTED");
    });

    ordersocket!.on("ORDER_ACCEPTED", (data) {
      print("🎉 ORDER_ACCEPTED SOCKET: $data");

      /// 🔥 SOCKET → API STATUS MAPPING
      onStatusUpdate({
        "orderId": data["orderId"],
        "status": "ACCEPTED", // 👈 API compatible
      });
    });

    ordersocket!.on("ORDER_PICKED_UP_BY_PARTNER", (data) {
      print("🎉 Out for delivery SOCKET: $data");
      onStatusUpdate({
        "orderId": data["orderId"],
        "status": "OUT_FOR_DELIVERY",
      });
    });

    ordersocket!.on("ORDER_DELIVERED", (data) {
      print("🎉 ORDER_Delivered Successfully SOCKET: $data");
      onStatusUpdate({"orderId": data["orderId"], "status": "DELIVERED"});
    });

    ordersocket!.on("OTP_SENT", (data) {
      onStatusUpdate({"orderId": data["orderId"], "otp": data["otp"]});
    });

    ordersocket!.on("CONNECTION_ESTABLISHED", (data) {
      print("🎉 ROOM JOINED: $data");
    });

    ordersocket!.on("ORDER_STATUS_UPDATE", onStatusUpdate);
    ordersocket!.on("ORDER_TRACKING_INFO", onTrackingInfo);
    ordersocket!.on("DELIVERY_ASSIGNED", onDeliveryAssigned);

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
