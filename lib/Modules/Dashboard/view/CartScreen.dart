import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/ProfileSection/view/profilemodel.dart';

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
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
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
    final restaurant = cartCtrl.cartResponse?.data?.cart?.restaurant;
    final summary = cartCtrl.cartResponse?.data?.cart?.summary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                      onTap: () => Get.back(),
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

                    // Only listening to real observable count
                    Obx(
                      () => CircleAvatar(
                        radius: 11,
                        backgroundColor: const Color(0xFF8B0000),
                        child: Text(
                          "${cartCtrl.totalCount}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // RESTAURANT SECTION
              if (restaurant != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
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
                ),

              const SizedBox(height: 14),

              // CART ITEMS LIST
              Obx(() {
                if (cartCtrl.cartItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Your cart is empty",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartCtrl.cartItems.length,
                  itemBuilder: (context, i) {
                    final item = cartCtrl.cartItems[i];

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                        left: 16,
                        right: 16,
                      ),
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

                          // NAME + QTY COUNTER + PRICE (All dynamic from .obs list)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"] ?? "",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF8B0000),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => cartCtrl.decreaseQty(i),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 18,
                                          color: Color(0xFF8B0000),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${item["qty"]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => cartCtrl.increaseQty(i),
                                        child: const Icon(
                                          Icons.add,
                                          size: 18,
                                          color: Color(0xFF8B0000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),
                                Text(
                                  "₹${item["itemTotal"]}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // DELETE BUTTON (Dynamic)
                          InkWell(
                            onTap: () => cartCtrl.removeItem(i),
                            child: const Icon(
                              Icons.delete_outline,
                              size: 22,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
              const Divider(),

              // BILL DETAILS — now reactive from controller
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Obx(() {
                  // Now GetX sees observable inside scope
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bill Details",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),

                      _buildBillRow("Subtotal", "₹${cartCtrl.subtotal}"),

                      _buildBillRow(
                        "Tax",
                        "₹${summary?.tax?.toStringAsFixed(2) ?? "0.00"}",
                      ),

                      _buildBillRow(
                        "Delivery",
                        summary?.deliveryCharge == 0
                            ? "Free"
                            : "₹${summary?.deliveryCharge ?? 0}",
                      ),

                      const Divider(),

                      _buildBillRow(
                        "Grand Total",
                        "₹${summary?.grandTotal?.toStringAsFixed(2)}",
                        isBold: true,
                        color: const Color(0xFF8B0000),
                      ),
                    ],
                  );
                }),
              ),

              // COUPON SECTION
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: TextField(
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
              ),

              const SizedBox(height: 12),

              // PAY BUTTON (Dynamic Grand Total)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Obx(
                  () => ElevatedButton(
                    onPressed: cartCtrl.isLoading.value ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "Pay ₹${summary?.grandTotal!.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
