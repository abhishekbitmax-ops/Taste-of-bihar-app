import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final CartController ctrl = Get.find<CartController>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // initial call
    ctrl.fetchOrderTracking(widget.orderId);

    // 🔄 auto refresh every 15 sec
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      ctrl.fetchOrderTracking(widget.orderId);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF8B0000)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Order Details",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B0000),
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B0000)),
          );
        }

        final order = ctrl.order.value;
        if (order == null) {
          return const Center(child: Text("No tracking data"));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _orderInfoCard(order),
            const SizedBox(height: 18),
            Text(
              "Delivery Partner Details",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 10),
            _deliveryPartner(order),
            const SizedBox(height: 18),
            _currentStatus(order.status),
            const SizedBox(height: 24),
            _timeline(order.status),
          ],
        );
      }),
    );
  }

  // ───────── ORDER INFO ─────────

  Widget _orderInfoCard(order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
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
          Text(
            "₹${order.price?.grandTotal ?? 0}",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8B0000),
            ),
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF8B0000),
            child: Icon(Icons.person, color: Colors.white),
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
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () {
              // later: launch("tel:$phone");
            },
          ),
        ],
      ),
    );
  }

  // ───────── CURRENT STATUS ─────────

  Widget _currentStatus(String? status) {
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

  // ───────── TIMELINE ─────────

  Widget _timeline(String? status) {
    final steps = ["PLACED", "ACCEPTED", "OUT_FOR_DELIVERY", "DELIVERED"];

    final labels = [
      "Placed",
      "Order Confirmed",
      "Out for Delivery",
      "Delivered",
    ];

    int activeIndex = steps.indexWhere((e) => e == status?.toUpperCase());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Timeline",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
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
                        size: 14,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
