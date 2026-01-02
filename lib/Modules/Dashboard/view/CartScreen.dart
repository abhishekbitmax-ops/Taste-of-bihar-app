import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/widgets/Addressbottomsheet.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController cartCtrl = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- CUSTOM TOP BAR ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  const Icon(Icons.favorite_border, color: Color(0xFF8B0000)),
                  const SizedBox(width: 16),
                  const Icon(Icons.more_horiz, color: Color(0xFF8B0000)),
                  const SizedBox(width: 8),
                  Obx(
                    () => cartCtrl.cartItems.isNotEmpty
                        ? CircleAvatar(
                            radius: 11,
                            backgroundColor: const Color(0xFF8B0000),
                            child: Text(
                              "${cartCtrl.totalCount}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ---------- RATING / DELIVERY INFO ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      cartCtrl.cartItems.isNotEmpty
                          ? cartCtrl.cartItems.last["image"]
                          : "assets/placeholder.png",
                      height: 46,
                      width: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Swaad of Grandmaa",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 15),
                          const SizedBox(width: 4),
                          Text(
                            "4.5  (5k+ ratings) • 30 mins",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.green.shade50,
                    ),
                    child: Text(
                      "Free delivery",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 🛒 CART ITEMS (Not wrapped in heavy Obx)
                    Column(
                      children: List.generate(cartCtrl.cartItems.length, (i) {
                        final item = cartCtrl.cartItems[i];
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 14,
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
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  item["image"],
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    // ✅ Only this small counter is reactive
                                    Obx(
                                      () => Container(
                                        height: 32,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF8B0000),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  cartCtrl.decreaseQty(i),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 18,
                                                  color: Color(0xFF8B0000),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${cartCtrl.cartItems[i]["qty"]}",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  cartCtrl.increaseQty(i),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 18,
                                                  color: Color(0xFF8B0000),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price + delete not reactive
                              Column(
                                children: [
                                  Text(
                                    "${item["price"]}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF8B0000),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () => cartCtrl.removeItem(i),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 10),

                    // 🎟 COUPON SECTION
                    cartCtrl.cartItems.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "10% OFF",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "Use code SAVOUR10",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "APPLY",
                                    style: TextStyle(
                                      color: Color(0xFF8B0000),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),

                    // 💰 BILL DETAILS (Reactive total only)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Obx(() {
                        final subtotal = cartCtrl.subtotal;
                        final total = subtotal - 79 + 3;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bill Details",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _buildBillRow("Subtotal", "₹$subtotal"),
                            _buildBillRow("Discount", "- ₹79"),
                            _buildBillRow("Delivery Fee", "free"),
                            const Divider(height: 16),
                            _buildBillRow(
                              "Total",
                              "₹$total",
                              isBold: true,
                              color: const Color(0xFF8B0000),
                            ),
                          ],
                        );
                      }),
                    ),

                    // ---------- ADDRESS SELECTOR (Already added) ----------
                    InkWell(
                      onTap: () => Get.bottomSheet(
                        const AddressSelector(heightFactor: 0.5),
                        isScrollControlled: true,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF555555),
                              size: 20,
                            ),
                            const SizedBox(width: 8),

                            // ✅ Selected address ko yaha live show karo
                            Expanded(
                              child: Obx(
                                () => Text(
                                  cartCtrl.selectedAddress.value,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF555555),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ---------- PAYING VIA + PAY BUTTON (Merged like image) ----------
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),

                        color: Colors.white,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRect(
                            child: Image.asset(
                              "assets/images/googlel.png",
                              height: 34,
                              width: 34,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "PAYING VIA ",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 25,
                                      color: Color(0xFF8B0000),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Paytm UPI",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // RIGHT SIDE : Pay Button (Reactive total)
                          Obx(() {
                            final payTotal = cartCtrl.subtotal;
                            return SizedBox(
                              width: 142,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B0000),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: Text(
                                  "Pay ₹$payTotal",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(
    String t,
    String v, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            t,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            v,
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
}
