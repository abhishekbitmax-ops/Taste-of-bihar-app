import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/Modules/Navbar/navbar.dart';
import 'package:taste_of_bihar/widgets/OrderTackingScreen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late Map<String, dynamic> order;

  @override
  void initState() {
    super.initState();

    order = Get.arguments ?? {};

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = order["orderId"]?.toString() ?? "N/A";
    final price = (order["price"]?["grandTotal"] ?? 0).toString();

    /// 🔥 PAYMENT METHOD (ROBUST)
    final rawType = (order["payment"]?["type"] ?? "").toString().toUpperCase();
    final rawMethod = (order["payment"]?["method"] ?? "")
        .toString()
        .toUpperCase();

    final paymentMethod =
        (rawType == "COD" || rawMethod == "COD" || rawMethod == "CASH")
        ? "Cash on Delivery"
        : "UPI Payment";

    /// 🔥 PAYMENT STATUS
    final rawStatus = (order["payment"]?["status"] ?? "PENDING")
        .toString()
        .toUpperCase();

    final paymentStatus = rawStatus == "PAID"
        ? "Paid"
        : rawType == "COD"
        ? "Pay on Delivery"
        : "Pending";

    final address = order["deliveryAddress"];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ SUCCESS ICON
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 70,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Order Placed Successfully 🎉",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Thank you for ordering with us",
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 22),

              // 📦 ORDER DETAILS CARD
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row("Order ID", orderId),
                      _row("Payment Method", paymentMethod),
                      _row("Payment Status", paymentStatus),
                      _row("Total Amount", "₹$price"),

                      const Divider(height: 26),

                      if (address != null &&
                          address["addressLine"] != null) ...[
                        _row("Name", address["name"] ?? "-"),
                        _row("Mobile", address["phone"] ?? "-"),
                        _row(
                          "Address",
                          "${address["addressLine"]}, "
                              "${address["city"]} - ${address["pincode"]}",
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // 🚚 TRACK ORDER
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final oid = order["orderId"];

                    if (oid == null || oid.toString().isEmpty) {
                      Get.snackbar("Error", "Invalid Order ID");
                      return;
                    }

                    Get.to(() => OrderTrackingScreen(orderId: oid.toString()));
                  },
                  child: const Text(
                    "Track Order",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🏠 BACK TO HOME
              TextButton(
                onPressed: () {
                  final cartCtrl = Get.find<CartController>();
                  cartCtrl.clearCartAfterOrder(); // ✅ IMPORTANT
                  Get.offAll(() => BottomNavBar(initialIndex: 0));
                },
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
