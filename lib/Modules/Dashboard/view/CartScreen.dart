import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Dashboard/view/ApplyCoupanscreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/widgets/Addressbottomsheet.dart';
import 'package:restro_app/widgets/RazorpayBottompay.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 🔥 IMPORTANT
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Obx(() {
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
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // TOP BAR
              // 🔥 PREMIUM GRADIENT HEADER
              // 🔥 FULL WIDTH GRADIENT HEADER (STATUS BAR INCLUDED)
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(
                  top:
                      MediaQuery.of(context).padding.top +
                      16, // 🔥 STATUS BAR SPACE
                  bottom: 26,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8B0000),
                      Color(0xFFB71C1C),
                      Color(0xFFD32F2F),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // 🔝 TOP BAR
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Get.until(
                                (route) =>
                                    route.settings.name == '/BottomNavBar',
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          "Cart",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.favorite_border, color: Colors.white),
                        const SizedBox(width: 16),
                        const Icon(Icons.more_horiz, color: Colors.white),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Text(
                            "${s?.itemCount ?? 0}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // 🏪 RESTAURANT CARD
                    if (restaurant != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                restaurant.image ?? "",
                                height: 56,
                                width: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  "assets/images/popular.png",
                                  height: 56,
                                  width: 56,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant.name ?? "",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.5 • 5k+ ratings",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Divider(),

              // CART ITEMS
              if (cartCtrl.cartItems.isEmpty)
                const Center(child: Text("Your cart is empty"))
              else
                for (int i = 0; i < cartCtrl.cartItems.length; i++)
                  _CartItemTile(index: i),

              // 🎟 Apply Coupon Card
              InkWell(
                onTap: () => Get.to(() => ApplyCouponScreen()),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1,
                      vertical: 5,
                    ),
                    padding: const EdgeInsets.all(10),
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
              ),
              const SizedBox(width: 15),
              Divider(),

              // BILL DETAILS
              if (s != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    //  vertical: 4.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bill Details",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildBillRow("Subtotal", "₹${s.subtotal ?? 0}"),
                        _buildBillRow(
                          "Tax",
                          "₹${s.tax?.toStringAsFixed(2) ?? "0.00"}",
                        ),
                        _buildBillRow(
                          "Delivery",
                          s.deliveryCharge == 0
                              ? "Free"
                              : "₹${s.deliveryCharge}",
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
                    ),
                  ),
                ),
              ],

              // const SizedBox(height: 10),

              // 📍 Delivery Address Selector Card (POLISHED)
              InkWell(
                onTap: () => Get.bottomSheet(
                  const AddressSelector(heightFactor: 0.5),
                  isScrollControlled: true,
                ),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF5F5), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF8B0000).withOpacity(0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // 🔴 LEFT ACCENT STRIP
                        Container(
                          width: 5,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B0000),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 📍 LOCATION ICON
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B0000).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFF8B0000),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 14),

                        // ADDRESS TEXT
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
                              const SizedBox(height: 4),
                              Obx(
                                () => Text(
                                  cartCtrl.selectedAddress.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ⬇️ DROPDOWN ICON
                        Container(
                          padding: const EdgeInsets.all(6),
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

                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),

              // PAY BUTTON
              // PAYMENT METHOD + PAY BUTTON ROW
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40,
                ), // 👈 LIFT FROM BOTTOM
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔽 PAYMENT DROPDOWN
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                    cartCtrl.selectedPaymentMethod.value =
                                        value;
                                  }
                                },
                              ),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: () async {
                                final savedAddressId =
                                    await SharedPre.getSelectedAddressId();

                                if (savedAddressId.isEmpty) {
                                  Get.snackbar(
                                    "Address Required",
                                    "Please select a delivery address",
                                  );
                                  return;
                                }

                                cartCtrl.selectedAddressId.value =
                                    savedAddressId;

                                final selected =
                                    cartCtrl.selectedPaymentMethod.value;

                                if (selected == "COD") {
                                  await cartCtrl.placeOrder(
                                    addressId: savedAddressId,
                                    paymentMethod: "COD",
                                  );
                                } else {
                                  cartCtrl.openRazorpaySheet(
                                    amount: cartCtrl.grandTotal.value,
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
                                  : const Text(
                                      "Place Order",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Container(
        // margin: const EdgeInsets.only(bottom: 16),
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
                    Row(
                      children: [
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
                        SizedBox(width: 6),
                        Text(
                          item["price"] ?? "Item",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
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
                                  color: isUpdating
                                      ? Colors.grey
                                      : Colors.green,
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
