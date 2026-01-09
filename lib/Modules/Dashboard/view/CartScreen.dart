import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

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
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back,
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
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: const Color(0xFF8B0000),
                    child: Text(
                      "${s?.itemCount ?? 0}",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item["image"] ?? "",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                "assets/images/popular.png",
                width: 60,
                height: 60,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"] ?? "",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                // QTY CONTROL BUTTONS
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => cartCtrl.decreaseQty(index),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => Text(
                              "${cartCtrl.cartItems[index]["qty"]}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => cartCtrl.increaseQty(index),
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  "₹${item["itemTotal"]}",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // DELETE BUTTON
          IconButton(
            onPressed: () => cartCtrl.removeItemApi(index),
            icon: const Icon(Icons.delete_outline, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
