import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Addressbottomsheet.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController cartCtrl = Get.find<CartController>();

  Widget _buildBillRow(
    String title,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final restaurant = cartCtrl.cartResponse?.data?.cart?.restaurant;
          final s = cartCtrl.cartResponse?.data?.cart?.summary;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Get.offAll(BottomNavBar(initialIndex: 0)),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF8B0000),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Cart",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B0000),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite_border, color: Color(0xFF8B0000)),
                    const SizedBox(width: 16),
                    const Icon(Icons.more_horiz, color: Color(0xFF8B0000)),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: const Color(0xFF8B0000),
                      child: Text(
                        "${s?.itemCount ?? 0}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // RESTAURANT SECTION
              if (restaurant != null)
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        restaurant.image ?? "",
                        height: 46,
                        width: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          "assets/images/popular.png",
                          height: 46,
                          width: 46,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        restaurant.name ?? "",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      "4.5  (5k+ ratings) • ",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CART ITEMS
              if (cartCtrl.cartItems.isEmpty)
                const Center(child: Text("Your cart is empty"))
              else
                for (int i = 0; i < cartCtrl.cartItems.length; i++)
                  _CartItemTile(index: i),

              const SizedBox(height: 20),

              // BILL DETAILS
              if (s != null) ...[
                const Text(
                  "Bill Details",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildBillRow("Subtotal", "₹${s.subtotal ?? 0}"),
                _buildBillRow("Tax", "₹${s.tax?.toStringAsFixed(2) ?? "0.00"}"),
                _buildBillRow(
                  "Delivery",
                  s.deliveryCharge == 0 ? "Free" : "₹${s.deliveryCharge ?? 0}",
                ),
                const Divider(),
                _buildBillRow(
                  "Grand Total",
                  "₹${s.grandTotal?.toStringAsFixed(2) ?? "0.00"}",
                  isBold: true,
                  color: const Color(0xFF8B0000),
                ),
              ],

              const SizedBox(height: 20),

              // COUPON INPUT
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter coupon code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Apply",
                      style: TextStyle(color: Color(0xFF8B0000)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 📍 Delivery Address Selector Card
              InkWell(
                onTap: () => Get.bottomSheet(
                  const AddressSelector(heightFactor: 0.5),
                  isScrollControlled: true,
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // 📍 Location Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF8B0000),
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Address Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Deliver to",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(
                              () => Text(
                                cartCtrl.selectedAddress.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dropdown Arrow
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PAY BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: cartCtrl.isLoading.value ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Pay ₹${s?.grandTotal?.toStringAsFixed(2) ?? "0.00"}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }
}

// Cart Item Tile extracted in separate widget
class _CartItemTile extends StatelessWidget {
  final CartController cartCtrl = Get.find<CartController>();
  final int index;

  _CartItemTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final item = cartCtrl.cartItems[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              item["image"] ?? "",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                "assets/images/popular.png",
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAME
                Text(
                  item["name"] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // QTY CONTROLLER
                Obx(() {
                  final isUpdating = cartCtrl.updatingIndex.value == index;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF3F3), Color(0xFFFFEAEA)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ➖
                        InkWell(
                          onTap: isUpdating
                              ? null
                              : () => cartCtrl.decreaseQty(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.shade50,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: isUpdating ? Colors.grey : Colors.red,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // LOADER / QTY
                        isUpdating
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "${cartCtrl.cartItems[index]["qty"]}",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                        const SizedBox(width: 14),

                        // ➕
                        InkWell(
                          onTap: isUpdating
                              ? null
                              : () => cartCtrl.increaseQty(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.shade50,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: isUpdating ? Colors.grey : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // PRICE + DELETE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => cartCtrl.removeItemApi(index),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),

              const SizedBox(height: 6),

              Text(
                "₹${item["itemTotal"]}",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B0000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
