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
  String selectedSubCategory = "";

  final Authcontroller authCtrl = Get.find<Authcontroller>();

  Future<void> _loadInitialSubCategoryItems() async {
    authCtrl.items.clear();
    selectedSubCategory = "";

    await authCtrl.fetchSubCategories(selectedCategoryId);

    if (authCtrl.subCategories.isNotEmpty) {
      final firstSubCategory = authCtrl.subCategories.first;
      selectedSubCategory = firstSubCategory.name ?? "";
      await authCtrl.fetchCategoryItems(firstSubCategory.sId ?? "");
    } else {
      authCtrl.items.clear();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args != null && args is Map) {
      selectedCategory = args["categoryName"] ?? "";
      selectedCategoryId = args["categoryId"] ?? "";
      _loadInitialSubCategoryItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ZomatoCartBar(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          selectedCategory.isNotEmpty ? selectedCategory : "Our Menu",
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
                if (authCtrl.isSubCategoryLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (authCtrl.subCategories.isEmpty) {
                  authCtrl.items.clear();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "No\nSubcategories",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: authCtrl.subCategories.length,
                  itemBuilder: (context, index) {
                    final subCategory = authCtrl.subCategories[index];
                    final bool isSelected =
                        selectedSubCategory == (subCategory.name ?? "");

                    return InkWell(
                      onTap: () {
                        final subCategoryId = subCategory.sId ?? "";
                        setState(() {
                          selectedSubCategory = subCategory.name ?? "";
                        });
                        authCtrl.fetchCategoryItems(subCategoryId);
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
                                    AppColors.background,
                                  ],
                                )
                              : null,
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
                              backgroundColor: isSelected
                                  ? Colors.white.withOpacity(0.95)
                                  : Colors.white,
                              child: ClipOval(
                                child: Image.network(
                                  subCategory.subCategoryImage ?? "",
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
                              subCategory.name ?? "",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
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
                    if (selectedCategory.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.background],
                          ),
                        ),
                        child: Text(
                          selectedSubCategory.isNotEmpty
                              ? "$selectedCategory | $selectedSubCategory"
                              : selectedCategory,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

                        if (authCtrl.subCategories.isEmpty) {
                          return Center(
                            child: Text(
                              "Subcategories not available",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
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
                                (item.menuImage != null &&
                                        item.menuImage!.isNotEmpty)
                                ? item.menuImage!
                                : "";

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 350 + (index * 90),
                              ),
                              curve: Curves.easeOutCubic,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.95,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: double.infinity,
                                        color: Colors.white,
                                        child: Padding(
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  InkWell(
                                                    onTap: () =>
                                                        openProductBottomSheet(
                                                          context,
                                                          {
                                                            "id": item.sId ?? "",
                                                            "name":
                                                                item.name ?? "",
                                                            "desc":
                                                                item.description ??
                                                                "",
                                                            "price": item
                                                                .basePrice
                                                                .toString(),
                                                            "image": imageUrl,
                                                            "type":
                                                                item.isVeg ==
                                                                    true
                                                                ? "veg"
                                                                : "nonveg",
                                                          },
                                                        ),
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 250,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 18,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              30,
                                                            ),
                                                        gradient:
                                                            const LinearGradient(
                                                              colors: [
                                                                AppColors
                                                                    .primary,
                                                                AppColors
                                                                    .background,
                                                              ],
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "ADD +",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 20),
                                    child: child,
                                  ),
                                );
                              },
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
                    colors: [AppColors.primary, AppColors.background],
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
