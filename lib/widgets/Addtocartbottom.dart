import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/utils/Sharedpre.dart';

bool _hasTimingWindow(Map<String, String> product) {
  return (product["orderStartTime"] ?? "").trim().isNotEmpty ||
      (product["orderEndTime"] ?? "").trim().isNotEmpty ||
      (product["deliveryStartTime"] ?? "").trim().isNotEmpty ||
      (product["deliveryEndTime"] ?? "").trim().isNotEmpty;
}

Future<bool> _canAddProductToCart(
  CartController cartCtrl,
  Map<String, String> product,
) async {
  if (cartCtrl.cartItems.isEmpty) return true;

  final savedTiming = await SharedPre.getCartTiming();
  final cartHasTiming =
      (savedTiming["orderStartTime"] ?? "").trim().isNotEmpty ||
      (savedTiming["orderEndTime"] ?? "").trim().isNotEmpty ||
      (savedTiming["deliveryStartTime"] ?? "").trim().isNotEmpty ||
      (savedTiming["deliveryEndTime"] ?? "").trim().isNotEmpty;
  final incomingHasTiming = _hasTimingWindow(product);

  if (cartHasTiming != incomingHasTiming) {
    Get.snackbar(
      "Cart Restriction",
      cartHasTiming
          ? "Timed menu items are already in your cart. Please complete or clear that cart before adding snacks, drinks, or events."
          : "Snacks, drinks, or event items are already in your cart. Please complete or clear that cart before adding breakfast, lunch, or dinner items.",
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
    );
    return false;
  }

  return true;
}

void openProductBottomSheet(BuildContext context, Map<String, String> product) {
  int qty = 1;
  final Authcontroller apiCtrl = Get.find<Authcontroller>();
  final CartController cartCtrl = Get.find<CartController>();
  final String unitPriceText = product["price"] ?? "";
  final int unitPrice =
      int.tryParse(unitPriceText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final int totalPrice = unitPrice * qty;
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: 1),
            builder: (_, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 28 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.74,
              maxChildSize: 0.9,
              minChildSize: 0.58,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 44,
                                  height: 5,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: -6,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 210,
                                  width: double.infinity,
                                  child:
                                      product["image"] == null ||
                                          product["image"]!.isEmpty
                                      ? Image.asset(
                                          "assets/images/popular.png",
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          product["image"]!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                                "assets/images/popular.png",
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                ),
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.45),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.92),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      unitPriceText,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            product["name"] ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product["desc"] ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              height: 1.45,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Quantity",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          if (qty > 1) {
                                            setModalState(() => qty--);
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.remove,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            ),
                                        child: Padding(
                                          key: ValueKey(qty),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            qty.toString(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => setModalState(() => qty++),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.add,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6EC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Text(
                                    key: ValueKey(totalPrice),
                                    unitPrice == 0
                                        ? unitPriceText
                                        : "Rs. $totalPrice",
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(() {
                            final bool loading = apiCtrl.isApiLoading.value;

                            return SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () async {
                                        final menuId = product["id"] ?? "";
                                        if (menuId.isEmpty) {
                                          Get.snackbar(
                                            "Error",
                                            "Menu item ID not found",
                                          );
                                          return;
                                        }

                                        final canAdd = await _canAddProductToCart(
                                          cartCtrl,
                                          product,
                                        );
                                        if (!canAdd) {
                                          return;
                                        }

                                        final result = await apiCtrl.addToCartApi(
                                          menuId,
                                          qty,
                                          "",
                                        );
                                        if (result["success"] != true) {
                                          Get.snackbar(
                                            "Error",
                                            result["message"] ??
                                                "Failed to add item",
                                          );
                                          return;
                                        }

                                        await SharedPre.saveCartTiming(
                                          categoryName:
                                              product["categoryName"] ?? "",
                                          orderStartTime:
                                              product["orderStartTime"] ?? "",
                                          orderEndTime:
                                              product["orderEndTime"] ?? "",
                                          deliveryStartTime:
                                              product["deliveryStartTime"] ?? "",
                                          deliveryEndTime:
                                              product["deliveryEndTime"] ?? "",
                                        );

                                        await cartCtrl.fetchCartApi();
                                        Navigator.pop(context);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: AppColors.primary
                                      .withOpacity(0.55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Add to Cart",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
