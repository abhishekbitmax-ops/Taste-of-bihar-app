import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Dashboard/view/ApplyCoupanscreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Addressbottomsheet.dart';
import 'package:restro_app/widgets/RazorpayBottompay.dart';

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

          if (cartCtrl.cartItems.isEmpty) {
            return _emptyCartView();
          }

          return RefreshIndicator(
            color: const Color(0xFF8B0000),
            onRefresh: () async {
              await cartCtrl.fetchCartApi();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
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
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Get.until(
                              (route) => route.settings.name == '/BottomNavBar',
                            );
                          });
                        },

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
                      const Icon(
                        Icons.favorite_border,
                        color: Color(0xFF8B0000),
                      ),
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

                const SizedBox(height: 10),
                Divider(),
                const SizedBox(height: 10),

                // CART ITEMS
                if (cartCtrl.cartItems.isEmpty)
                  const Center(child: Text("Your cart is empty"))
                else
                  for (int i = 0; i < cartCtrl.cartItems.length; i++)
                    _CartItemTile(index: i),

                const SizedBox(height: 20),

                // 🎟 Apply Coupon Card
                InkWell(
                  onTap: () => Get.to(() => ApplyCouponScreen()),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF1F1), Color(0xFFFFE0E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF8B0000).withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 🎟️ COUPON ICON WITH BADGE
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B0000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_offer,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),

                            // 🔥 10% OFF BADGE
                            Positioned(
                              top: -6,
                              right: -10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "10% OFF",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Apply Coupon",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF8B0000),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Save 10% instantly on this order",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 👉 ARROW
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Color(0xFF8B0000),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 25),
                Divider(),

                // BILL DETAILS
                if (s != null) ...[
                  const Text(
                    "Bill Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildBillRow("Subtotal", "₹${s.subtotal ?? 0}"),
                  _buildBillRow(
                    "Tax",
                    "₹${s.tax?.toStringAsFixed(2) ?? "0.00"}",
                  ),
                  _buildBillRow(
                    "Delivery",
                    s.deliveryCharge == 0
                        ? "Free"
                        : "₹${s.deliveryCharge ?? 0}",
                  ),
                  _buildBillRow(
                    "Discount",
                    "-₹${s.discount?.toStringAsFixed(2) ?? "0.00"}",
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

                // 📍 Delivery Address Selector Card
                InkWell(
                  onTap: () => Get.bottomSheet(
                    const AddressSelector(heightFactor: 0.5),
                    isScrollControlled: true,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
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
                // PAYMENT METHOD + PAY BUTTON ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔽 PAYMENT DROPDOWN
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Obx(
                          () => DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: cartCtrl.selectedPaymentMethod.value,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: cartCtrl.paymentMethods
                                  .map(
                                    (method) => DropdownMenuItem(
                                      value: method,
                                      child: Text(
                                        method,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  cartCtrl.selectedPaymentMethod.value = value;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 💳 PAY BUTTON
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 48,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: () {
                              if (cartCtrl.selectedAddressId.value.isEmpty) {
                                Get.snackbar(
                                  "Address Required",
                                  "Please select a delivery address",
                                );
                                return;
                              }

                              final selected =
                                  cartCtrl.selectedPaymentMethod.value;

                              if (selected == "Cash on Delivery") {
                                // ✅ COD FLOW SAME
                                cartCtrl.placeOrder(
                                  addressId: cartCtrl.selectedAddressId.value,
                                  paymentMethod: "COD",
                                );
                              } else {
                                // ✅ UPI FLOW — ONLY OPEN DIALOG
                                Get.dialog(
                                  PaymentBottomSheet(
                                    amount: cartCtrl.grandTotal.value,
                                  ),
                                  barrierDismissible: false,
                                );
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: cartCtrl.isPlacingOrder.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Place Order",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7F7), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF8B0000).withOpacity(0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔴 LEFT ACCENT STRIP
          Container(
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF8B0000),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // IMAGE
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 14),
            child: ClipRRect(
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
          ),

          const SizedBox(width: 14),

          // DETAILS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  Text(
                    item["name"] ?? "Item",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // QTY CONTROLLER
                  Obx(() {
                    final isUpdating = cartCtrl.updatingIndex.value == index;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8B0000).withOpacity(0.25),
                        ),
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
                              padding: const EdgeInsets.all(6),
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
                                  "${item["qty"]}",
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
                              padding: const EdgeInsets.all(6),
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
          ),

          // PRICE + DELETE
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  final isRemoving = cartCtrl.removingIndex.value == index;

                  return isRemoving
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: () => cartCtrl.removeItemApi(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                        );
                }),

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
          ),
        ],
      ),
    );
  }
}

Widget _emptyCartView() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🛒 ICON CONTAINER
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: Color(0xFF8B0000),
            ),
          ),

          const SizedBox(height: 20),

          // TITLE
          Text(
            "Your cart is empty",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8B0000),
            ),
          ),

          const SizedBox(height: 8),

          // SUBTITLE
          Text(
            "Looks like you haven’t added\nanything to your cart yet",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 26),

          // 🏠 BACK TO HOME BUTTON
          SizedBox(
            width: 200,
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.off(() => BottomNavBar(initialIndex: 0));
                });
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: Text(
                "Back to Home",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
