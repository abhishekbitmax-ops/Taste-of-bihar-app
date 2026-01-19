import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Dashboard/model/Dashboardmodel.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/widgets/OrderTackingScreen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final CartController ctrl = Get.put(CartController());

  @override
  void initState() {
    super.initState();

    /// 🔥 AUTO REFRESH WHEN SCREEN OPENS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Orders",
          style: GoogleFonts.poppins(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B0000)),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B0000)),
          );
        }

        if (ctrl.orders.isEmpty) {
          return _emptyOrderView();
        }

        /// 🔥 SORT ALL ORDERS BY TIME (LATEST FIRST)
        final sortedOrders = [...ctrl.orders];
        sortedOrders.sort((a, b) {
          final da = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
          final db = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
          return db.compareTo(da);
        });

        /// 🔥 ACTIVE ORDERS (NOT DELIVERED)
        final activeOrders = sortedOrders
            .where((o) => (o.status ?? "").toUpperCase() != "DELIVERED")
            .toList();

        /// 🔥 SORT ACTIVE ORDERS BY TIME
        activeOrders.sort((a, b) {
          final da = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
          final db = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
          return db.compareTo(da);
        });

        /// 🔥 ONLY ONE LATEST ACTIVE ORDER
        OrderData? latestActiveOrder = activeOrders.isNotEmpty
            ? activeOrders.first
            : null;

        return RefreshIndicator(
          color: const Color(0xFF8B0000),
          onRefresh: () async {
            await ctrl.fetchOrderHistory();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 🔥 TOP — LATEST ACTIVE ORDER
              if (latestActiveOrder != null) ...[
                Text(
                  "Latest Order",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B0000),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: () {
                    Get.to(
                      () => OrderTrackingScreen(
                        orderId: latestActiveOrder!.orderId!,
                      ),
                    );
                  },
                  child: _OrderHistoryCard(latestActiveOrder!, isLatest: true),
                ),

                const SizedBox(height: 24),
              ],

              /// 🔥 REST OF ORDERS (HISTORY)
              ...sortedOrders
                  .where((o) => o.orderId != latestActiveOrder?.orderId)
                  .map(
                    (order) => InkWell(
                      onTap: () {
                        Get.to(
                          () => OrderTrackingScreen(orderId: order.orderId!),
                        );
                      },
                      child: _OrderHistoryCard(order),
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}

/// ─────────────────────────────────────────────
/// ORDER CARD
/// ─────────────────────────────────────────────
class _OrderHistoryCard extends StatelessWidget {
  final OrderData order;
  final bool isLatest;

  const _OrderHistoryCard(this.order, {this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    final address = order.deliveryAddress;
    final status = (order.status ?? "").toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF5F5), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF8B0000).withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          /// TOP STRIP
          Container(
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// RESTAURANT + STATUS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.restaurant?.name ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (isLatest && status != "DELIVERED") ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "ONGOING",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B0000).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B0000),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                /// ORDER ID
                Text(
                  "Order ID: ${order.orderId ?? ""}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 8),

                /// ITEMS
                Text(
                  order.items
                          ?.map((e) => "${e.name} x${e.quantity}")
                          .join(", ") ??
                      "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),

                const SizedBox(height: 8),

                /// ADDRESS
                if (address != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF8B0000),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${address.addressLine ?? ""}, "
                          "${address.city ?? ""} - ${address.pincode ?? ""}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),
                Divider(color: Colors.grey.shade300),

                /// PRICE + TRACK
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${order.price?.grandTotal ?? 0}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B0000),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (order.orderId == null) return;
                        Get.to(
                          () => OrderTrackingScreen(orderId: order.orderId!),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Track Order",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// EMPTY STATE
/// ─────────────────────────────────────────────
Widget _emptyOrderView() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.receipt_long, size: 90, color: Color(0xFF8B0000)),
        const SizedBox(height: 16),
        Text(
          "No orders yet",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B0000),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Your past orders will appear here",
          style: GoogleFonts.poppins(color: Colors.black54),
        ),
      ],
    ),
  );
}
