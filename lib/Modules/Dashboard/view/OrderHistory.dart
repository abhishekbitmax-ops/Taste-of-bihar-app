import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Dashboard/model/Dashboardmodel.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';
import 'package:restro_app/widgets/OrderHistorydetails.dart';

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen({super.key});

  final CartController ctrl = Get.put(CartController());

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

        /// 🔥 SORT ORDERS (LATEST FIRST)
        final sortedOrders = [...ctrl.orders];
        sortedOrders.sort((a, b) {
          final da = DateTime.tryParse(a.createdAt ?? "") ?? DateTime(0);
          final db = DateTime.tryParse(b.createdAt ?? "") ?? DateTime(0);
          return db.compareTo(da);
        });

        return RefreshIndicator(
          color: const Color(0xFF8B0000),
          onRefresh: () async {
            await ctrl.fetchOrderHistory();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedOrders.length,
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
              return InkWell(
                onTap: () {
                  Get.to(() => OrderDetailScreen(order: order));
                },
                child: _OrderHistoryCard(order, isLatest: index == 0),
              );
            },
          ),
        );
      }),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderData order; // ✅ FIXED
  final bool isLatest;

  const _OrderHistoryCard(this.order, {this.isLatest = false});

  @override
  Widget build(BuildContext context) {
    final address = order.deliveryAddress;

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
                    if (isLatest) ...[
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
                          "LATEST",
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
                const SizedBox(height: 8),
                Text(
                  order.items
                          ?.map((e) => "${e.name} x${e.quantity}")
                          .join(", ") ??
                      "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                if (address != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      formatOrderDate(order.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
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

String formatOrderDate(String? date) {
  if (date == null || date.isEmpty) return "";
  final dt = DateTime.tryParse(date);
  if (dt == null) return "";
  return "${dt.day}/${dt.month}/${dt.year} • "
      "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
}

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
