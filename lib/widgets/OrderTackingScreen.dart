import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:restro_app/Modules/Dashboard/view/Socket_service.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Globalnotifation.dart';
import 'package:restro_app/widgets/Googlemapbottomsheet.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ctrl.fetchOrderTracking(widget.orderId);

      final order = ctrl.order.value;
      if (order?.deliveryAddress != null) {
        ctrl.hasUserLocation.value = true;
      }
    });
  }

  Widget _trackOrderButton(order) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Get.bottomSheet(
            LiveTrackingBottomSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.white,
          );
        },
        icon: const Icon(Icons.location_on),
        label: Text(
          "Track Order Live",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
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

              // 🔥 OTP CARD (SHOW PROMINENTLY WHEN AVAILABLE - TOP PRIORITY)
              if (order.effectiveOtp != null &&
                  order.effectiveOtp!.isNotEmpty) ...[
                _otpCard(order),
                const SizedBox(height: 16),
              ],

              // 🔥 SHOW TRACK BUTTON WHEN OTP AVAILABLE
              if (order.effectiveOtp != null &&
                  order.effectiveOtp!.isNotEmpty) ...[
                _trackOrderButton(order),
                const SizedBox(height: 16),
              ],

              // 🔥 SHOW DELIVERY PARTNER WHEN ASSIGNED (HAS PARTNER DATA)
              if (order.delivery?.partner != null) ...[
                _deliveryPartner(order),
                const SizedBox(height: 16),
              ],

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
    final partner = order.delivery?.partner;

    if (partner == null) return const SizedBox();

    final name = partner.name ?? "Unknown";
    final phone = partner.phone ?? "N/A";
    final vehicle = partner.vehicle?.type;

    return _card(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF8B0000),
            child: Icon(Icons.delivery_dining, color: Colors.white),
          ),
          const SizedBox(width: 12),

          /// 👤 NAME + PHONE + VEHICLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                if (vehicle != null && vehicle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    vehicle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),

          /// 📞 CALL ICON
          InkWell(
            onTap: () {
              // future: launch dialer with phone
              // launchUrl(Uri(scheme: 'tel', path: phone));
            },
            child: const Icon(Icons.call, color: Colors.green, size: 22),
          ),
        ],
      ),
    );
  }

  // ───────── OTP ─────────
  Widget _otpCard(order) {
    /// 🔥 GET OTP FROM BOTH SOURCES (API + Socket)
    final otp = order.effectiveOtp;
    if (otp == null || otp.isEmpty) return const SizedBox();

    return _card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Delivery OTP",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Text(
                    otp,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Share this with delivery partner",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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

    String? time;
    int? minutes;
    String? message;

    /// 🔥 CASE 1: API sent STRING
    if (eta is String) {
      time = eta;
    }

    /// 🔥 CASE 2: API sent OBJECT
    if (eta is Map<String, dynamic>) {
      time = eta["time"];
      minutes = eta["minutes"];
      message = eta["message"];
    }

    String timeText = "";
    try {
      if (time != null) {
        final dt = DateTime.parse(time);
        timeText = DateFormat('hh:mm a').format(dt.toLocal());
      }
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
                  "${minutes ?? "--"} mins"
                  "${timeText.isNotEmpty ? " • by $timeText" : ""}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
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

    // 🔥 VERY IMPORTANT: normalize status
    final currentStatus = status?.toUpperCase().trim() ?? "";
    int activeIndex = steps.indexOf(currentStatus);

    // fallback safety (prevents -1 bug)
    if (activeIndex < 0) activeIndex = 0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Timeline",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF8B0000),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: List.generate(steps.length, (i) {
              final isCompleted = i < activeIndex;
              final isActive = i == activeIndex;

              final dotColor = (isCompleted || isActive)
                  ? Colors.green
                  : Colors.grey.shade400;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DOT + LINE
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i != steps.length - 1)
                          Container(
                            width: 2,
                            height: 28,
                            color: isCompleted
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    /// LABEL
                    Expanded(
                      child: Text(
                        labels[i],
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: (isCompleted || isActive)
                              ? Colors.black87
                              : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
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
