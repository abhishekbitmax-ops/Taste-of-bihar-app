import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/view/CartScreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/widgets/Addtocartbottom.dart';
import 'package:restro_app/widgets/Viewcartbar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String foodFilter = "all"; // all, veg, nonveg
  String selectedCategory = "";
  String selectedCategoryId = "";

  final Authcontroller authCtrl = Get.find<Authcontroller>();

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null && args is Map) {
      selectedCategory = args["categoryName"] ?? "";
      selectedCategoryId = args["categoryId"] ?? "";
      authCtrl.fetchCategoryItems(selectedCategoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ZomatoCartBar(),

      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        title: const Text("Our Menu", style: TextStyle(color: Colors.white)),
        actions: [
          // 🛒 CART ICON
          InkWell(
            onTap: () {
              Get.to(() => CartScreen()); // 🔥 OPEN CART
            },
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                // 🔴 CART COUNT BADGE
                Positioned(
                  right: 2,
                  top: 2,
                  child: Obx(() {
                    final cartCtrl = Get.find<CartController>();
                    final count = cartCtrl.cartItems.length;

                    if (count == 0) return const SizedBox();

                    return CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text(
                        "$count",
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // 🔍 SEARCH ICON
          const Icon(Icons.search, color: Colors.white),

          const SizedBox(width: 12),
        ],
      ),

      body: SafeArea(
        child: Row(
          children: [
            // LEFT CATEGORY MENU
            Container(
              width: 110,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFEBEE), // very light red (top)
                    Color(0xFFFFFFFF), // white (bottom)
                  ],
                ),
              ),
              child: Obx(() {
                return ListView.builder(
                  itemCount: authCtrl
                      .categories
                      .length, // ✔ all categories show (even duplicate names)
                  itemBuilder: (context, index) {
                    final cat = authCtrl.categories[index];
                    bool isSelected =
                        selectedCategoryId ==
                        cat.id; // ✔ only 1 selected at a time

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat.name ?? "";
                          selectedCategoryId =
                              cat.id ?? ""; // ✔ unique ID store
                        });
                        authCtrl.fetchCategoryItems(selectedCategoryId);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 6,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),

                          gradient: isSelected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFD32F2F), // red
                                    Color(0xFFFF7043), // orange
                                  ],
                                )
                              : null,

                          color: isSelected ? null : Colors.white,

                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.network(
                                  cat.image ?? "",
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    "assets/images/popular.png",
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name ?? "",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // RIGHT PRODUCT LIST + FILTER BUTTONS
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  children: [
                    // FILTER BUTTONS
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          _filterButton("Veg", "veg"),
                          const SizedBox(width: 8),
                          _filterButton("Non-Veg", "nonveg"),
                        ],
                      ),
                    ),

                    // PRODUCT LIST FROM API
                    Expanded(
                      child: Obx(() {
                        if (authCtrl.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var itemList = authCtrl.items;

                        if (foodFilter == "veg") {
                          itemList = itemList
                              .where((i) => i.isVeg == true)
                              .toList()
                              .obs;
                        } else if (foodFilter == "nonveg") {
                          itemList = itemList
                              .where((i) => i.isVeg == false)
                              .toList()
                              .obs;
                        }
                        if (itemList.isEmpty) {
                          return const Center(
                            child: Text(
                              "No item available",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: itemList.length,
                          itemBuilder: (_, index) {
                            final item = itemList[index];

                            final String imageUrl =
                                (item.image != null && item.image!.isNotEmpty)
                                ? item.image!
                                : "";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// IMAGE
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            "assets/images/popular.png",
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          item.description ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          children: [
                                            Text(
                                              "₹${item.basePrice ?? 0}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF8B0000),
                                              ),
                                            ),
                                            const Spacer(),
                                            InkWell(
                                              onTap: () =>
                                                  openProductBottomSheet(
                                                    context,
                                                    {
                                                      "id": item.id ?? "",
                                                      "name": item.name ?? "",
                                                      "desc":
                                                          item.description ??
                                                          "",
                                                      "price": item.basePrice
                                                          .toString(),
                                                      "image": imageUrl,
                                                      "type": item.isVeg == true
                                                          ? "veg"
                                                          : "nonveg",
                                                    },
                                                  ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF8B0000),
                                                          Color(0xFFB71C1C),
                                                        ],
                                                      ),
                                                ),
                                                child: const Text(
                                                  "ADD +",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    bool isActive = foodFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => foodFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFB71C1C)],
                  )
                : null,
            color: isActive ? null : Colors.grey.shade200,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == "veg" ? Icons.eco : Icons.local_fire_department,
                size: 16,
                color: isActive ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
