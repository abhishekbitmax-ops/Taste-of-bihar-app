import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/view/CartScreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Addtocartbottom.dart';
import 'package:restro_app/widgets/Viewcartbar.dart';
import 'package:shimmer/shimmer.dart';

class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  final Authcontroller authCtrl = Get.find<Authcontroller>();
  final CartController popularCtrl = Get.find<CartController>();

  RxString address = "Fetching location...".obs;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      authCtrl.fetchBanners(); // ✅ ONLY ONCE
      await authCtrl.fetchCategories();

      // ✅ FETCH POPULAR DISHES HERE
      await popularCtrl.fetchPopularDishes();

      if (authCtrl.categories.isNotEmpty) {
        selectedCategory.value = authCtrl.categories.first.name ?? "";
        selectedCategoryId.value = authCtrl.categories.first.id ?? "";
        authCtrl.fetchCategoryItems(selectedCategoryId.value);
      }
    });
  }

  RxString selectedCategory = "".obs;
  RxString selectedCategoryId = "".obs;

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        address.value = "Location service disabled";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        address.value = "Location permission denied";
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      address.value =
          "${place.name}, ${place.subLocality}, "
          "${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
    } catch (e) {
      address.value = "Unable to fetch location";
    }
  }

  Widget recommendedCard(String img, String name) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          img,
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ZomatoCartBar(),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: authCtrl.refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // APP BAR WITH CURRENT LOCATION
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF8B0000)),
                      const SizedBox(width: 6),

                      Expanded(
                        child: Obx(
                          () => Text(
                            address.value,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),

                      // 🛒 CART ICON (NEW)
                      InkWell(
                        onTap: () {
                          Get.to(() => CartScreen()); //  OPEN CART
                        },
                        child: Stack(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 26,
                                color: Color(0xFF8B0000),
                              ),
                            ),

                            // 🔴 CART COUNT BADGE
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Obx(() {
                                final cartCtrl = Get.find<CartController>();
                                final count = cartCtrl.cartItems.length;

                                if (count == 0) return const SizedBox();

                                return CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    "$count",
                                    style: const TextStyle(
                                      fontSize: 10,
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

                      const SizedBox(width: 10),

                      // 🔔 NOTIFICATION ICON
                      const Icon(Icons.notifications_none, size: 26),
                    ],
                  ),
                ),

                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search for restaurants or dishes",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                //  DYNAMIC OFFER BANNER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Obx(() {
                      // ✅ SHIMMER WHILE LOADING
                      if (authCtrl.isBannerLoading.value) {
                        return bannerShimmer();
                      }

                      // ✅ NO DATA STATE
                      if (authCtrl.banners.isEmpty) {
                        return const SizedBox(
                          height: 160,
                          child: Center(child: Text("No banners available")),
                        );
                      }

                      return Stack(
                        children: [
                          SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: PageView.builder(
                              controller: authCtrl.pageController,
                              onPageChanged: (i) {
                                authCtrl.currentIndex.value = i;
                              },
                              itemCount: authCtrl.banners.length,
                              itemBuilder: (context, i) {
                                final banner = authCtrl.banners[i];

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    /// 🔹 IMAGE
                                    Image.network(
                                      banner.image ?? "",
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        "assets/images/delas.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    /// 🔹 GRADIENT
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.65),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),

                                    /// 🔹 TITLE + DESCRIPTION
                                    Positioned(
                                      left: 14,
                                      right: 14,
                                      bottom: 18,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if ((banner.title ?? "").isNotEmpty)
                                            Text(
                                              banner.title!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                          if ((banner.description ?? "")
                                              .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                banner.description!,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          /// 🔴 DOT INDICATOR
                          Positioned(
                            bottom: 6,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                authCtrl.banners.length,
                                (i) => Obx(() {
                                  final isActive =
                                      authCtrl.currentIndex.value == i;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: isActive ? 18 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 26),

                // EXPLORE CATEGORY TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        "Explore by Category",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),

                      InkWell(
                        onTap: () => Get.offAll(
                          () => const BottomNavBar(initialIndex: 2),
                        ),
                        child: Text(
                          "See All",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // CATEGORY SECTION WITH HORIZONTAL SCROLL
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() {
                      // ✅ SHIMMER WHILE LOADING
                      if (authCtrl.isCategoryLoading.value) {
                        return categoryShimmer();
                      }

                      // ✅ NO DATA STATE (after API)
                      if (authCtrl.categories.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "No categories found",
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      }

                      // ✅ CATEGORY LIST
                      return Row(
                        children: authCtrl.categories.map((cat) {
                          final bool hasImage =
                              cat.image != null && cat.image!.isNotEmpty;

                          return InkWell(
                            onTap: () {
                              selectedCategory.value = cat.name ?? "";
                              selectedCategoryId.value = cat.id ?? "";

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Get.offAll(
                                  () => const BottomNavBar(initialIndex: 2),
                                  arguments: {
                                    "categoryId": cat.id ?? "",
                                    "categoryName": cat.name ?? "",
                                  },
                                );
                              });
                            },

                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 14),
                              child: Column(
                                children: [
                                  Container(
                                    width: 74,
                                    height: 74,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: SweepGradient(
                                        startAngle: -1.57,
                                        endAngle: 1.57,
                                        colors: [
                                          Color(0xFF8B0000),
                                          Color(0xFF1E88E5),
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: ClipOval(
                                          child: hasImage
                                              ? Image.network(
                                                  cat.image!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Image.asset(
                                                        "assets/images/Dine.jpg",
                                                        fit: BoxFit.cover,
                                                      ),
                                                )
                                              : Image.asset(
                                                  "assets/images/Dine.jpg",
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat.name ?? "Unknown",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF8B0000),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // POPULAR RESTAURANTS (Restored Old Style - Horizontal, White BG, No Shadow)
                // POPULAR DISHES (VERTICAL STYLE)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        "Popular Dishes",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Obx(() {
                        if (popularCtrl.isLoading.value) {
                          return popularDishShimmer(); // 🔥
                        }

                        if (popularCtrl.popularDishes.isEmpty) {
                          return const Center(
                            child: Text("No popular dishes found"),
                          );
                        }

                        return Column(
                          children: popularCtrl.popularDishes.map((dish) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: popularDishFullCard(
                                image: dish.image?.isNotEmpty == true
                                    ? dish.image ?? ""
                                    : "assets/images/popular.png",
                                name: dish.name ?? "Unknown",
                                description:
                                    dish.description?.isNotEmpty == true
                                    ? dish.description!
                                    : "Delight in every bite",
                                rating:
                                    dish.rating?.toStringAsFixed(1) ?? "0.0",
                                category: dish.isVeg == true
                                    ? "Veg"
                                    : "Non-Veg",
                                time: "${dish.totalSold ?? 0} sold",
                                price: "₹${dish.price ?? 0}",
                                onAdd: () {
                                  openProductBottomSheet(context, {
                                    "id": dish.id ?? "",
                                    "name": dish.name ?? "",
                                    "desc": dish.description ?? "",
                                    "price": "₹${dish.price ?? 0}",
                                    "image": dish.image ?? "",
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget popularDishShimmer() {
  return Column(
    children: List.generate(3, (index) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SHIMMER
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.white,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 16,
                      width: 160,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DESCRIPTION
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 12,
                      width: 220,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BOTTOM ROW
                  Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 12,
                          width: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 12,
                          width: 80,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 28,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
    }),
  );
}

Widget categoryShimmer() {
  return Row(
    children: List.generate(6, (index) {
      return Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(width: 50, height: 10, color: Colors.white),
            ),
          ],
        ),
      );
    }),
  );
}

Widget bannerShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

Widget popularDishFullCard({
  required String image,
  required String name,
  required String description,
  required String rating,
  required String category,
  required String time,
  required String price,
  VoidCallback? onAdd,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FULL IMAGE
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: image.startsWith("http")
              ? Image.network(
                  image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    "assets/images/popular.png",
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAME + ADD BUTTON
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B0000),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFF8B0000)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "ADD",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 2),

              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),

              // CATEGORY
              Text(
                category,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 8),

              // RATING + TIME + PRICE
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(rating, style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(width: 12),
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(time, style: GoogleFonts.poppins(fontSize: 12)),
                  const Spacer(),
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B0000),
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
}
