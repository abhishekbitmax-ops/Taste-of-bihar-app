import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final address = order.deliveryAddress;
    final price = order.price;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B0000)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Order Details",
          style: GoogleFonts.poppins(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🧾 ORDER ID + STATUS
          _sectionCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order ID", style: GoogleFonts.poppins(fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8B0000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 🏪 RESTAURANT
          _sectionCard(
            title: "Restaurant",
            child: Text(
              order.restaurant?.name ?? "",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 📍 DELIVERY ADDRESS
          if (address != null)
            _sectionCard(
              title: "Delivery Address",
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(0xFF8B0000),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${address.name}\n${address.addressLine}, ${address.city} - ${address.pincode}",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // 🍽 ORDER ITEMS
          _sectionCard(
            title: "Items",
            child: Column(
              children: order.items!
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item.name} x${item.quantity}",
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ),
                          Text(
                            "₹${item.finalItemPrice}",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // 💰 BILL DETAILS
          _sectionCard(
            title: "Bill Details",
            child: Column(
              children: [
                _billRow("Items Total", price?.itemsTotal),
                _billRow("Tax", price?.tax),
                _billRow("Delivery Fee", price?.deliveryFee),
                _billRow("Discount", price?.discount, isDiscount: true),
                const Divider(),
                _billRow("Grand Total", price?.grandTotal, isBold: true),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 💳 PAYMENT
          _sectionCard(
            title: "Payment",
            child: Text(
              "${order.payment?.method} • ${order.payment?.status}",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------- HELPERS ----------

  Widget _sectionCard({String? title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B0000).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }

  Widget _billRow(
    String label,
    int? value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            "${isDiscount ? "-" : ""}₹${value ?? 0}",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? const Color(0xFF8B0000) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
