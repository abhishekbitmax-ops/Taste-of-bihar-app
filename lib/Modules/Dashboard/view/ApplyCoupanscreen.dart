import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/CartScreen.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/utils/app_color.dart';

class ApplyCouponScreen extends StatelessWidget {
  ApplyCouponScreen({super.key});

  final CartController cartCtrl = Get.find<CartController>();
  final TextEditingController couponCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await cartCtrl.fetchAvailableCoupons();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.background.withOpacity(0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      color: AppColors.background,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: couponCtrl,
                        style: GoogleFonts.poppins(
                          color: AppColors.softLight,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter coupon code",
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.softLight.withOpacity(0.65),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFBD5A0A), AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.softLight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          onPressed:
                              cartCtrl.applyingCouponCode.value.isNotEmpty ||
                                  cartCtrl.cartItems.isEmpty
                              ? null
                              : () async {
                                  final code = couponCtrl.text.trim();

                                  if (code.isEmpty) {
                                    Get.snackbar(
                                      "Error",
                                      "Please enter coupon code",
                                    );
                                    return;
                                  }

                                  final success = await cartCtrl.applyCouponApi(
                                    code,
                                  );

                                  if (success) {
                                    Get.to(CartScreen());
                                  }
                                },
                          child:
                              cartCtrl.applyingCouponCode.value.isNotEmpty &&
                                  cartCtrl.applyingCouponCode.value ==
                                      couponCtrl.text.trim()
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.softLight,
                                  ),
                                )
                              : Text(
                                  "APPLY",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Available Coupons",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GetBuilder<CartController>(
                initState: (_) {
                  Future.microtask(() => cartCtrl.fetchAvailableCoupons());
                },
                builder: (_) {
                  if (cartCtrl.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.background),
                      ),
                    );
                  }

                  if (cartCtrl.availableCoupons.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.background.withOpacity(0.28),
                        ),
                      ),
                      child: Text(
                        "No coupons available",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.softLight.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: cartCtrl.availableCoupons.map((coupon) {
                      return _CouponTile(
                        code: coupon.code ?? "",
                        desc: coupon.description ?? "",
                        cartCtrl: cartCtrl,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardDark.withOpacity(0.92),
              AppColors.bgStart.withOpacity(0.94),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.background.withOpacity(0.32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer, color: AppColors.background),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: GoogleFonts.poppins(
                      color: AppColors.softLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.softLight.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB65508), AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.softLight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed:
                      cartCtrl.applyingCouponCode.value.isNotEmpty ||
                          cartCtrl.cartItems.isEmpty
                      ? null
                      : () async {
                          final success = await cartCtrl.applyCouponApi(code);
                          if (success) {
                            Get.to(CartScreen());
                          }
                        },
                  child: cartCtrl.applyingCouponCode.value == code
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.softLight,
                          ),
                        )
                      : Text(
                          "APPLY",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
