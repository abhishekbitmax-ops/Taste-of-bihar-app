import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/CartScreen.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/utils/app_color.dart';

class ZomatoCartBar extends StatelessWidget {
  ZomatoCartBar({super.key});

  final CartController cartCtrl = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cartCtrl.cartItems.isEmpty) return const SizedBox.shrink();

      final summary = cartCtrl.cartResponse?.data?.cart?.summary;
      final double tax = summary?.tax ?? 0;
      final int discount = summary?.discount ?? 0;
      final int delivery = summary?.deliveryCharge ?? 0;
      final int totalCount = summary?.itemCount ?? 0;
      final double total =
          summary?.grandTotal ??
          (summary?.subtotal ?? 0) + tax - discount + delivery;

      return Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: AppColors.primary,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$totalCount item${totalCount > 1 ? "s" : ""} added",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "\u20B9${total.toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    cartCtrl.fetchCartApi();
                    Get.to(() => CartScreen());
                  },
                  child: Text(
                    "View cart >",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
