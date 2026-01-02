import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:restro_app/Modules/Dashboard/view/CartScreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

class ZomatoCartBar extends StatelessWidget {
  final CartController cartCtrl = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (cartCtrl.cartItems.isEmpty) return const SizedBox();

      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF8B0000), // Zomato red tone
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                cartCtrl.cartItems.last["image"],
                height: 34,
                width: 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "${cartCtrl.totalCount} item added",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () => Get.to(() => CartScreen()),
              child: Row(
                children: const [
                  Text(
                    "View cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
