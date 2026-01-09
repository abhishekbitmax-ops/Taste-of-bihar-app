import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

void openProductBottomSheet(BuildContext context, Map<String, String> product) {
  int qty = 1;
  final Authcontroller apiCtrl =
      Get.find<Authcontroller>(); // existing auth controller
  final CartController cartCtrl =
      Get.find<CartController>(); // 👈 existing cart controller use

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          (product["image"] == null ||
                              product["image"]!.isEmpty)
                          ? Image.asset(
                              "assets/images/popular.png",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              product["image"]!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                "assets/images/popular.png",
                                height: 150,
                                width: 220,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product["name"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product["desc"]!,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Price: ${product["price"]}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quantity Counter
                  Center(
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (qty > 1) setModalState(() => qty--);
                            },
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 26,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                          Text(
                            qty.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setModalState(() => qty++),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              size: 26,
                              color: Color(0xFF8B0000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Add to Cart Button
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      bool loading = apiCtrl.isApiLoading.value;
                      return ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                                String menuId = product["id"] ?? "";
                                if (menuId.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Menu item ID not found",
                                  );
                                  return;
                                }

                                await apiCtrl.addToCartApi(menuId, qty, "");
                                await apiCtrl.addToCartApi(menuId, qty, "");
                                await cartCtrl
                                    .fetchCartApi(); // 👈 CART KO REFRESH API SE

                                // cartCtrl.addToCart(product, qty);
                                // await cartCtrl.fetchCartApi();
                                Navigator.pop(context);
                              },
                        icon: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.shopping_cart_checkout,
                                color: Colors.white,
                              ),
                        label: Text(
                          loading ? "Adding..." : "Add to Cart",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
