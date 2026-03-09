import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Dashboard/model/Dashboardmodel.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:taste_of_bihar/widgets/OrderTackingScreen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final CartController ctrl = Get.put(CartController());

  static const activeStatuses = ["PLACED", "ACCEPTED", "OUT_FOR_DELIVERY"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          "My Orders",
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F1F1F),
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F1F1F)),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (ctrl.orders.isEmpty) {
          return _emptyOrderView();
        }

        final sortedOrders = [...ctrl.orders];
        sortedOrders.sort((a, b) {
          final da = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
          final db = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
          return db.compareTo(da);
        });

        final latestOrder = sortedOrders.isNotEmpty ? sortedOrders.first : null;
        final historyOrders = sortedOrders
            .where((o) => o.orderId != latestOrder?.orderId)
            .toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await ctrl.fetchOrderHistory();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (latestOrder != null) ...[
                Text(
                  "Latest Order",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF202020),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Get.to(
                      () => OrderTrackingScreen(orderId: latestOrder.orderId!),
                    );
                  },
                  child: _OrderHistoryCard(
                    latestOrder,
                    isLatest: activeStatuses.contains(
                      (latestOrder.status ?? "").toUpperCase(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Order History",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF202020),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ...List.generate(historyOrders.length, (index) {
                final order = historyOrders[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.95, end: 1),
                  duration: Duration(milliseconds: 280 + (index * 60)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 24),
                        child: child,
                      ),
                    );
                  },
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Get.to(
                        () => OrderTrackingScreen(orderId: order.orderId!),
                      );
                    },
                    child: _OrderHistoryCard(order),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderData order;
  final bool isLatest;

  const _OrderHistoryCard(this.order, {this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    final status = (order.status ?? "").toUpperCase();
    final restaurantName = order.restaurant?.name ?? "Taste of Bihar";
    final orderItems =
        order.items?.map((e) => "${e.name} x${e.quantity}").join(", ") ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFC7640B)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        restaurantName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F1F1F),
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
                          color: const Color(0xFFEAF8ED),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "ONGOING",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F8A35),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEAD6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Order ID: ${order.orderId ?? "-"}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  orderItems,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Rs ${order.price?.grandTotal ?? 0}",
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB65508), AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(
                            () => OrderTrackingScreen(orderId: order.orderId!),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          "Track Order",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
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

Widget _emptyOrderView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECECEC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2E7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "No orders yet",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Your past orders will appear here",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: const Color(0xFF757575)),
            ),
          ],
        ),
      ),
    ),
  );
}
