import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

void openProductBottomSheet(BuildContext context, Map<String, String> product) {
  int qty = 1;
  final Authcontroller apiCtrl = Get.find<Authcontroller>();
  final CartController cartCtrl = Get.find<CartController>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.85,
            minChildSize: 0.55,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== TOP HANDLE =====
                        
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        // ===== IMAGE =====
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child:
                                  product["image"] == null ||
                                      product["image"]!.isEmpty
                                  ? Image.asset(
                                      "assets/images/popular.png",
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      product["image"]!,
                                      height: 190,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        "assets/images/popular.png",
                                        height: 190,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),

                            // Gradient overlay
                            Container(
                              height: 190,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
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
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ===== NAME =====
                        Text(
                          product["name"] ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // ===== DESCRIPTION =====
                        Text(
                          product["desc"] ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ===== PRICE =====
                        Text(
                          product["price"] ?? "",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8B0000),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ===== QUANTITY SELECTOR =====
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (qty > 1) {
                                      setModalState(() => qty--);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 26,
                                    color: Color(0xFF8B0000),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  qty.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                InkWell(
                                  onTap: () => setModalState(() => qty++),
                                  child: const Icon(
                                    Icons.add_circle_outline,
                                    size: 26,
                                    color: Color(0xFF8B0000),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ===== ADD TO CART BUTTON =====
                        Obx(() {
                          bool loading = apiCtrl.isApiLoading.value;

                          return SizedBox(
                            width: double.infinity,
                            height: 52,
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

                                      await apiCtrl.addToCartApi(
                                        menuId,
                                        qty,
                                        "",
                                      );
                                      await cartCtrl.fetchCartApi();
                                      Navigator.pop(context);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B0000),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
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
          );
        },
      );
    },
  );
}
