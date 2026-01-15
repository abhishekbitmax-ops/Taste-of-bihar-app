import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final CartController ctrl = Get.find<CartController>();

  @override
  void initState() {
    super.initState();

    /// 🔥 FIRST API CALL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchOrderTracking(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 🔥 removes back button
        title: Text(
          "Track Order",
          style: GoogleFonts.poppins(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              color: Color(0xFF8B0000),
              size: 26,
            ),
            onPressed: () {
              /// 🏠 Go to Home
              Get.offAll(() => BottomNavBar(initialIndex: 0));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        color: const Color(0xFF8B0000),
        onRefresh: () => ctrl.fetchOrderTracking(widget.orderId),
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B0000)),
            );
          }

          final order = ctrl.order.value;
          if (order == null) {
            return const Center(
              child: Text(
                "Fetching order details...",
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _orderSummary(order),
              const SizedBox(height: 16),

              _deliveryPartner(order),
              const SizedBox(height: 16),

              _otpCard(order),
              const SizedBox(height: 16),

              /// 🔥 ETA CARD
              _estimatedDelivery(order),
              const SizedBox(height: 20),

              _timeline(order.status),
              const SizedBox(height: 16),

              _lastUpdated(order.createdAt),
            ],
          );
        }),
      ),
    );
  }

  // ───────── ORDER SUMMARY ─────────
  Widget _orderSummary(order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.restaurant?.name ?? "",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Order ID: ${order.orderId}",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF8B0000)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${order.deliveryAddress?.addressLine}, "
                  "${order.deliveryAddress?.city} - "
                  "${order.deliveryAddress?.pincode}",
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${order.price?.grandTotal ?? 0}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B0000),
                ),
              ),
              _statusChip(order.status),
            ],
          ),
        ],
      ),
    );
  }

  // ───────── DELIVERY PARTNER ─────────
  Widget _deliveryPartner(order) {
    final name = order.deliveryAddress?.name;
    final phone = order.deliveryAddress?.phone;
    if (name == null || phone == null) return const SizedBox();

    return _card(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF8B0000),
            child: Icon(Icons.delivery_dining, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.call, color: Colors.green),
        ],
      ),
    );
  }

  // ───────── OTP ─────────
  Widget _otpCard(order) {
    final otp = order.delivery?.otp;
    if (otp == null || otp.isEmpty) return const SizedBox();

    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Delivery OTP",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          Text(
            otp,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ───────── STATUS CHIP ─────────
  Widget _statusChip(String? status) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B0000).withOpacity(0.12),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          status ?? "",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B0000),
          ),
        ),
      ),
    );
  }

  // ───────── ESTIMATED DELIVERY ─────────
  Widget _estimatedDelivery(order) {
    final eta = order.estimatedDelivery;
    if (eta == null) return const SizedBox();

    String timeText = "";
    try {
      final dt = DateTime.parse(eta.time);
      timeText = DateFormat('hh:mm a').format(dt.toLocal());
    } catch (_) {}

    return _card(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Colors.green,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estimated Delivery",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${eta.minutes ?? "--"} mins"
                  "${timeText.isNotEmpty ? " • by $timeText" : ""}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                if (eta.message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    eta.message!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────── TIMELINE ─────────
  Widget _timeline(String? status) {
    final steps = ["PLACED", "ACCEPTED", "OUT_FOR_DELIVERY", "DELIVERED"];
    final labels = [
      "Order Placed",
      "Restaurant Accepted",
      "Out for Delivery",
      "Delivered",
    ];

    int activeIndex = steps.indexWhere((e) => e == status?.toUpperCase());

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Timeline",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B0000),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(steps.length, (i) {
              final isActive = i <= activeIndex;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                      if (i != steps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: isActive ? Colors.green : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      labels[i],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ───────── LAST UPDATED ─────────
  Widget _lastUpdated(String? createdAt) {
    String time = "--";

    if (createdAt != null && createdAt.isNotEmpty) {
      try {
        final parsedDate = DateFormat(
          'dd MMM yyyy hh:mm:ss a',
        ).parse(createdAt);

        time = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
      } catch (_) {
        // fallback if parsing fails
        time = createdAt;
      }
    }

    return Center(
      child: Text(
        "Last updated: $time\nPull down to refresh",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
      ),
    );
  }

  // ───────── COMMON CARD ─────────
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
