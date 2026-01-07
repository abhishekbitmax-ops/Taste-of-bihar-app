import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/view/menuscreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/Modules/Navbar/navbar.dart';
import 'package:restro_app/widgets/Addtocartbottom.dart';
import 'package:restro_app/widgets/Viewcartbar.dart';

class BannerSliderController extends GetxController {
  final PageController pageController = PageController();
  int currentIndex = 0;

  final List<String> banners = [
    "assets/images/delas.png",
    "assets/images/delas.png",
    "assets/images/delas.png",
  ];

  late final Timer timer;

  @override
  void onInit() {
    super.onInit();
    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      int next = (currentIndex + 1) % banners.length;
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      currentIndex = next;
      update();
    });
  }

  void updateIndex(int i) {
    currentIndex = i;
    update();
  }

  @override
  void onClose() {
    timer.cancel();
    pageController.dispose();
    super.onClose();
  }
}

class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  final Authcontroller authCtrl = Get.put(Authcontroller());

  @override
  void initState() {
    super.initState();
    authCtrl.fetchCategories().then((_) {
      if (authCtrl.categories.isNotEmpty) {
        setState(() {
          selectedCategory = authCtrl.categories[0].name ?? "";
          selectedCategoryId = authCtrl.categories[0].id ?? "";
        });
        authCtrl.fetchCategoryItems(selectedCategoryId);
      }
    });
  }

  String selectedCategory = ""; // 👈 ADD THIS
  String selectedCategoryId = "";
  Future<String> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return "Location service disabled";

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return "Permission denied";
    }

    if (permission == LocationPermission.deniedForever) {
      return "Permission permanently denied";
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;
    return "${place.street}, ${place.locality}";
  }

  Widget _buildCategory(String image, String label) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(image, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
    RxString address = "Fetching location...".obs;
    _getCurrentLocation().then((value) => address.value = value);

    final bannerController = PageController();
    RxInt bannerIndex = 0.obs;

    return Scaffold(
      bottomNavigationBar: ZomatoCartBar(),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF8B0000)),
                    const SizedBox(width: 6),
                    Obx(
                      () => Text(
                        address.value,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const Spacer(),
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

              // OFFER BANNER WITH AUTO ROUND SCROLL + INDICATOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GetBuilder<BannerSliderController>(
                    init: BannerSliderController(),
                    builder: (ctrl) => Stack(
                      children: [
                        SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: PageView.builder(
                            controller: ctrl.pageController,
                            onPageChanged: ctrl.updateIndex,
                            itemCount: ctrl.banners.length,
                            itemBuilder: (context, i) =>
                                Image.asset(ctrl.banners[i], fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(ctrl.banners.length, (i) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: ctrl.currentIndex == i ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      onTap: () =>
                          Get.offAll(() => const BottomNavBar(initialIndex: 2)),
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
                    if (authCtrl.categories.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "No categories found",
                          style: TextStyle(fontSize: 13),
                        ),
                      );
                    }

                    return Row(
                      children: authCtrl.categories.map((cat) {
                        final img = (cat.image == null || cat.image!.isEmpty)
                            ? "assets/images/Dine.jpg"
                            : "assets/images/${cat.image}";

                        return InkWell(
                          onTap: () {
                            // store selected ID
                            setState(() {
                              selectedCategory = cat.name ?? "";
                              selectedCategoryId = cat.id ?? "";
                            });

                            // 🚀 open navbar index 2 with arguments
                            Get.offAll(
                              () => BottomNavBar(initialIndex: 2),
                              arguments: {
                                "categoryId": cat.id ?? "",
                                "categoryName": cat.name ?? "",
                              },
                            );
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 14),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    img,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      "assets/images/Dine.jpg",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
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
                    InkWell(
                      onTap: () =>
                          Get.offAll(() => const BottomNavBar(initialIndex: 2)),
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
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      dishCard(context, {
                        "name": "Shahi Paneer",
                        "desc": "North indian ",
                        "price": "₹399",
                        "image": "assets/images/popular.png",
                      }),
                      dishCard(context, {
                        "name": "Burger King",
                        "desc": "Cheesy burger",
                        "price": "₹499",
                        "image": "assets/images/popular.png",
                      }),
                      dishCard(context, {
                        "name": "Dominos",
                        "desc": "Farmhouse ",
                        "price": "₹699",
                        "image": "assets/images/popular.png",
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // RECOMMENDED FOR YOU (Vertical + Image Details Below)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Recommended for you",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _recommendedItem(
                      "assets/images/popular.png",
                      "La Pino'z Pizza",
                      "4.7",
                      "Italian",
                      "30 mins",
                    ),
                    const SizedBox(height: 18),
                    _recommendedItem(
                      "assets/images/popular.png",
                      "Barbeque Nation",
                      "4.5",
                      "Indian BBQ",
                      "45 mins",
                    ),
                    const SizedBox(height: 18),
                    _recommendedItem(
                      "assets/images/popular.png",
                      "Burger Singh",
                      "4.3",
                      "Fast Food",
                      "25 mins",
                    ),
                    const SizedBox(height: 18),
                    _recommendedItem(
                      "assets/images/popular.png",
                      "Haldiram's",
                      "4.6",
                      "Sweets & Snacks",
                      "20 mins",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _recommendedItem(
  String img,
  String name,
  String rating,
  String cuisine,
  String time,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade300, width: 1.2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          child: Image.asset(
            img,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.green),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "$cuisine • ⏱ $time",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.delivery_dining,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Free Delivery Available",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.shade700,
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

Widget dishCard(BuildContext context, Map<String, String> product) {
  return Container(
    width: 170,
    margin: const EdgeInsets.only(right: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300, width: 1.2),
    ),
    child: Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.asset(
                product["image"]!,
                width: 170,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    product["desc"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product["price"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B0000),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ✅ Add + Button (Overlay Bottom Right)
        Positioned(
          bottom: 4,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000),
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              onTap: () => openProductBottomSheet(
                context,
                product,
              ), // 🔥 sheet opens here
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
        ),
      ],
    ),
  );
}
