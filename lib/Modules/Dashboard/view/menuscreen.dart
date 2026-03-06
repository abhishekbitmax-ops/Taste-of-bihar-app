import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/CartScreen.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:taste_of_bihar/widgets/Addtocartbottom.dart';
import 'package:taste_of_bihar/widgets/Viewcartbar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String foodFilter = "all";
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
        backgroundColor: AppColors.primary,
        title: Text(
          "Our Menu",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Get.to(() => CartScreen());
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
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 112,
              margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: authCtrl.categories.length,
                  itemBuilder: (context, index) {
                    final cat = authCtrl.categories[index];
                    final bool isSelected = selectedCategoryId == cat.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedCategory = cat.name ?? "";
                          selectedCategoryId = cat.id ?? "";
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
                          borderRadius: BorderRadius.circular(14),
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    Color(0xFFC7640B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFFFAF7F2),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE7DDCF),
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
                              style: GoogleFonts.poppins(
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
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
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
                          return Center(
                            child: Text(
                              "No item available",
                              style: GoogleFonts.poppins(
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
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFE7DCCB),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
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
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.95,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 9,
                                                color: item.isVeg == true
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                item.isVeg == true
                                                    ? "Veg"
                                                    : "Non-Veg",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              "\u20B9${item.basePrice ?? 0}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
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
                                                          AppColors.primary,
                                                          Color(0xFFC7640B),
                                                        ],
                                                      ),
                                                ),
                                                child: Text(
                                                  "ADD +",
                                                  style: GoogleFonts.poppins(
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
    final bool isActive = foodFilter == value;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => foodFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFC7640B)],
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
                style: GoogleFonts.poppins(
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
