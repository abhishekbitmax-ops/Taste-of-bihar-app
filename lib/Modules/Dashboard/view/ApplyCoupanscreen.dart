import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

class ApplyCouponScreen extends StatelessWidget {
  ApplyCouponScreen({super.key});

  final CartController cartCtrl = Get.find<CartController>();
  final TextEditingController couponCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Apply Coupon",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔍 COUPON INPUT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponCtrl,
                    decoration: InputDecoration(
                      hintText: "Enter coupon code",
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ),
                Obx(
                  () => TextButton(
                    onPressed: cartCtrl.isLoading.value
                        ? null
                        : () async {
                            if (couponCtrl.text.trim().isEmpty) {
                              Get.snackbar(
                                "Error",
                                "Please enter coupon code",
                              );
                              return;
                            }

                            final success = await cartCtrl.applyCouponApi(
                              couponCtrl.text.trim(),
                            );

                            if (success) {
                              Get.back(); // 👈 back to CartScreen
                            }
                          },
                    child: cartCtrl.isLoading.value
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "APPLY",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF8B0000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🎟 AVAILABLE COUPONS
          Text(
            "Available Coupons",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          _CouponTile(
            code: "SAVE50",
            desc: "Get ₹50 off on orders above ₹299",
            cartCtrl: cartCtrl,
          ),
          _CouponTile(
            code: "FREEDEL",
            desc: "Free delivery on your order",
            cartCtrl: cartCtrl,
          ),
          _CouponTile(
            code: "WELCOME100",
            desc: "₹100 off for new users",
            cartCtrl: cartCtrl,
          ),
        ],
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  final String code;
  final String desc;
  final CartController cartCtrl;

  const _CouponTile({
    required this.code,
    required this.desc,
    required this.cartCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Color(0xFF8B0000)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => TextButton(
              onPressed: cartCtrl.isLoading.value
                  ? null
                  : () async {
                      final success =
                          await cartCtrl.applyCouponApi(code);
                      if (success) {
                        Get.back(); // 👈 back to CartScreen
                      }
                    },
              child: cartCtrl.isLoading.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "APPLY",
                      style: TextStyle(
                        color: Color(0xFF8B0000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
