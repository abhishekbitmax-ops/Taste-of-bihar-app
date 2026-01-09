import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
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

  final Authcontroller authCtrl = Get.put(Authcontroller());

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
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // LEFT CATEGORY MENU
            Container(
              width: 110,
              color: Colors.white,
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8B0000)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF8B0000),
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                cat.image ?? "",
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  "assets/images/popular.png",
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.name ?? "Unknown",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF8B0000),
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

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      item.foodType == "img"
                                          ? item.id ?? ""
                                          : item.id ?? "",
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        "assets/images/popular.png",
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.name ?? "",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.foodType ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.variants?.join(", ") ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "₹${item.basePrice ?? 0}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF8B0000),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B0000),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () =>
                                              openProductBottomSheet(context, {
                                                "id": item.id ?? "",
                                                "name": item.name ?? "",
                                                "desc": item.description ?? "",
                                                "price": item.basePrice
                                                    .toString(),
                                                "image": item.id ?? "",
                                                "type": item.isVeg == true
                                                    ? "veg"
                                                    : "nonveg",
                                              }),
                                          child: const Text(
                                            "Add +",
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF8B0000) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
