import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

void openProductBottomSheet(BuildContext context, Map<String, String> product) {
  int qty = 1;

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
                      child: Image.asset(
                        product["image"]!,
                        height: 150,
                        width: 220,
                        fit: BoxFit.cover,
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

                  // const Spacer(),

                  // Quantity Counter
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (qty > 1) {
                              setModalState(() => qty--);
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 26,
                          ),
                          color: const Color(0xFF8B0000),
                        ),

                        Text(
                          qty.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setModalState(() => qty++);
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 26),
                          color: const Color(0xFF8B0000),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Add to Cart Button
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final CartController cartCtrl = Get.put(
                            CartController(),
                          );

                          cartCtrl.addToCart(product, qty);

                          debugPrint(
                            "Added to cart: ${product["name"]}  Qty: $qty",
                          );

                          Navigator.pop(context);
                        },

                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
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
