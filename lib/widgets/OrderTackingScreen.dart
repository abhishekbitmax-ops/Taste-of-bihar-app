import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Googlemapbottomsheet.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final CartController ctrl = Get.find<CartController>();

  Future<void> _callDeliveryPartner(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Get.snackbar(
        "Unavailable",
        "Delivery partner phone number not available",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        "Error",
        "Could not open phone dialer",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool _isOnlinePayment(order) {
    final method = order.payment?.method?.toUpperCase() ?? "";
    return method == "UPI" || method == "RAZORPAY" || method == "ONLINE";
  }

  bool _canCancel(String? status) {
    if (status == null) return false;
    final s = status.toUpperCase();
    return s == "PLACED" || s == "ACCEPTED";
  }

  String getRefundIdText() {
    final refund = ctrl.refund.value;

    // ❌ No refund object at all
    if (refund == null) {
      return "Refund not initiated yet";
    }

    final refunds = refund.refunds;

    // ⏳ Refund requested but ID not generated
    if (refunds == null || refunds.isEmpty) {
      return "Refund is being processed";
    }

    // ✅ Refund ID available
    return refunds.first.refundId ?? "Refund is being processed";
  }

  String getPaymentText(order) {
    if (order.payment == null) return "Cash on Delivery";

    if (order.payment?.method == null) {
      return "Cash on Delivery";
    }

    return order.payment!.method!;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ctrl.fetchOrderTracking(widget.orderId);

      if (ctrl.order.value?.status == "CANCELLED") {
        await ctrl.fetchRefund(widget.orderId); // 🔥 ADD THIS
      }

      final order = ctrl.order.value;
      if (order?.deliveryAddress != null) {
        ctrl.hasUserLocation.value = true;
      }
    });
  }

  Widget _refundRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13)),
          Text(
            value ?? "--",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
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
        icon: const Icon(Icons.location_on, color: Colors.white),
        label: Text(
          "Track Order Live",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
        onRefresh: () async {
          await ctrl.fetchOrderTracking(widget.orderId);

          // 🔥 IF ORDER IS CANCELLED → FETCH REFUND AGAIN
          if (ctrl.order.value?.status == "CANCELLED") {
            await ctrl.fetchRefund(widget.orderId);
          }
        },
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
            children: [
              /// 🔴 CANCELLED BANNER
              if (order.status == "CANCELLED") ...[
                if (_isOnlinePayment(order)) ...[
                  /// ✅ ONLINE → SHOW REFUND DETAILS
                  Obx(() {
                    final refund = ctrl.refund.value;
                    if (refund == null) return const SizedBox();

                    return _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Refund Details",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _refundRow("Refund ID", getRefundIdText()),
                          _refundRow("Refund Status", refund.refundStatus),
                          _refundRow(
                            "Amount Refunded",
                            "₹${refund.totalRefunded ?? 0}",
                          ),
                          _refundRow(
                            "Refund Request",
                            refund.refundRequest?.status,
                          ),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  /// ✅ COD → SHOW SIMPLE MESSAGE ONLY
                  _card(
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "This was a Cash on Delivery order.\nNo online refund is applicable.",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              if (_canCancel(order.status)) ...[
                _cancelOrderButton(order),
                const SizedBox(height: 16),
              ],

              _orderSummary(order),
              const SizedBox(height: 16),

              if (order.effectiveOtp?.isNotEmpty == true) ...[
                _otpCard(order),
                const SizedBox(height: 16),
                _trackOrderButton(order),
                const SizedBox(height: 16),
              ],

              if (order.delivery?.partner != null) ...[
                _deliveryPartner(order),
                const SizedBox(height: 16),
              ],

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

  Widget _cancelOrderButton(order) {
    return GestureDetector(
      onTap: () => _showCancelConfirmation(order),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08), // 🔥 soft red
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withOpacity(0.35), width: 1.2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              "Cancel Order",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(order) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),

              Text(
                "Cancel Order?",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Are you sure you want to cancel this order?\nThis action cannot be undone.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("No"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Get.back(); // close dialog
                        final method = order.payment?.method?.toUpperCase();

                        final cancelPaymentMethod =
                            (method == "ONLINE" ||
                                method == "RAZORPAY" ||
                                method == "UPI")
                            ? "ONLINE"
                            : "COD";

                        await ctrl.cancelOrder(
                          orderId: order.orderId!,
                          amount: (order.price?.grandTotal ?? 0).toDouble(),
                          paymentMethod: cancelPaymentMethod,
                          paymentId: order.payment?.transactionId,
                        );
                      },
                      child: const Text(
                        "Yes, Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // 👈 user must choose Yes / No
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
            onTap: () => _callDeliveryPartner(phone),
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
