import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Dashboard/view/CartScreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

class ZomatoCartBar extends StatelessWidget {
  final CartController cartCtrl = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cartCtrl.cartItems.isEmpty) return const SizedBox();

      final summary = cartCtrl.cartResponse?.data?.cart?.summary;
      double tax = summary?.tax ?? 0;
      int discount = summary?.discount ?? 0;
      int delivery = summary?.deliveryCharge ?? 0;
      int totalCount = summary?.itemCount ?? 0;
      double total =
          summary?.grandTotal ??
          (summary?.subtotal ?? 0) + tax - discount + delivery;

      return Container(
        height: 62, // 👈 chhota height
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32), // 👈 pill shape
          color: const Color(0xFF8B0000), // 👈 Zomato red
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🍽 last added image
            ClipOval(
              child: Image.network(
                cartCtrl.cartItems.last["image"] ?? "",
                height: 36,
                width: 36,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/popular.png",
                  height: 36,
                  width: 36,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Text Section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${totalCount} item${totalCount > 1 ? "s" : ""} added",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "₹${total.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // View Cart Button
            InkWell(
              onTap: () {
                cartCtrl.fetchCartApi();
                Get.to(() => CartScreen());
              },
              child: Text(
                "View cart ›",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
