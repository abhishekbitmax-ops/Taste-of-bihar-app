import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';

import 'package:shimmer/shimmer.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Dashboard/model/Snaksmodel.dart'
    as quick_model;
import 'package:taste_of_bihar/Modules/Dashboard/view/CartScreen.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/MenuEntryScreen.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/menuscreen.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/Notification.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/Modules/Navbar/navbar.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:taste_of_bihar/widgets/Addtocartbottom.dart';
import 'package:taste_of_bihar/widgets/Viewcartbar.dart';

class FoodHomeScreen extends StatefulWidget {
  const FoodHomeScreen({super.key});

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen>
    with SingleTickerProviderStateMixin {
  final Authcontroller authCtrl = Get.find<Authcontroller>();
  final CartController popularCtrl = Get.find<CartController>();
  late final AnimationController _partyBombController;

  RxString address = "Fetching location...".obs;

  final List<Color> _surfaceGradient = const [
    Color(0x99FFFBF6),
    Color(0x99FDF3E6),
    Color(0x99F8E9D8),
  ];

  void _openCategoryMenu(quick_model.CategoryData category) {
    Get.to(
      () => const MenuScreen(),
      arguments: {
        "categoryName": category.name ?? "",
        "categoryId": category.id ?? "",
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _partyBombController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      authCtrl.fetchBanners(); // ✅ ONLY ONCE
      if (authCtrl.quickCategories.isEmpty) {
        await authCtrl.fetchQuickCategories();
      }
      await authCtrl.fetchQuickCategoryItems();

      // ✅ keep other home data ready
      await popularCtrl.fetchPopularDishes();
    });
  }

  @override
  void dispose() {
    _partyBombController.dispose();
    super.dispose();
  }

  Widget _animatedEntry({
    required Widget child,
    int delayMs = 0,
    Duration duration = const Duration(milliseconds: 550),
    double offsetY = 28,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration + Duration(milliseconds: delayMs),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * offsetY),
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
    );
  }

  Widget _buildPartyButton() {
    return AnimatedBuilder(
      animation: _partyBombController,
      builder: (context, child) {
        final pulse =
            1 + (math.sin(_partyBombController.value * math.pi * 2) * 0.035);

        return Transform.scale(scale: pulse, child: child);
      },
      child: InkWell(
        onTap: () => Get.offAll(() => const BottomNavBar(initialIndex: 2)),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF7A18), Color(0xFFFFB347), Color(0xFFFF4D6D)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7A18).withOpacity(0.34),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Party Mode",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tap to open party offers",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      bottomNavigationBar: ZomatoCartBar(),
      backgroundColor: const Color(0xFFFFFAF4),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _surfaceGradient,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -90,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFC890).withOpacity(0.20),
                ),
              ),
            ),
            Positioned(
              top: 180,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFE6B8).withOpacity(0.30),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.72,
                  child: Lottie.asset(
                    'assets/lottie/partybomb.json',
                    controller: _partyBombController,
                    fit: BoxFit.cover,
                    repeat: false,
                  ),
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: authCtrl.refreshHome,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        24,
                        MediaQuery.of(context).padding.top + 14,
                        24,
                        24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF1D2237), AppColors.primary],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Taste of Bihar",
                                      style: GoogleFonts.poppins(
                                        fontSize: 29,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Fresh food made with love",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5,
                                        color: Colors.white.withOpacity(0.88),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => Get.to(() => NotificationScreen()),
                                borderRadius: BorderRadius.circular(18),
                                child: Obx(() {
                                  final count = popularCtrl.unreadCount;
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_none,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      if (count > 0)
                                        Positioned(
                                          right: -5,
                                          top: -5,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Center(
                                              child: Text(
                                                count > 9
                                                    ? "9+"
                                                    : count.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () => Get.to(() => CartScreen()),
                                borderRadius: BorderRadius.circular(18),
                                child: Obx(() {
                                  final cartCtrl = Get.find<CartController>();
                                  final count = cartCtrl.cartItems.length;
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      if (count > 0)
                                        Positioned(
                                          right: -5,
                                          top: -5,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "$count",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _buildPartyButton(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _animatedEntry(
                      delayMs: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 210,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFE67E22,
                                ).withOpacity(0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Obx(() {
                              if (authCtrl.isBannerLoading.value) {
                                return bannerShimmer();
                              }
                              if (authCtrl.banners.isEmpty) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFFB347),
                                        Color(0xFFFF7043),
                                        Color(0xFF8E44AD),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text("No banners available"),
                                  ),
                                );
                              }

                              return Stack(
                                children: [
                                  SizedBox(
                                    height: 210,
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
                                            Image.network(
                                              banner.image ?? "",
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset(
                                                    "assets/images/delas.png",
                                                    fit: BoxFit.cover,
                                                  ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    const Color(
                                                      0xFFFF8A65,
                                                    ).withOpacity(0.78),
                                                    const Color(
                                                      0xFFFFC107,
                                                    ).withOpacity(0.45),
                                                    const Color(
                                                      0xFF7B1FA2,
                                                    ).withOpacity(0.72),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(
                                                      0.62,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 16,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 7,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.20),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.45),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .local_fire_department,
                                                      size: 15,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "Chef Special",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.white,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: -10,
                                              top: -14,
                                              child: Container(
                                                width: 92,
                                                height: 92,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                                      .withOpacity(0.14),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 18,
                                              right: 18,
                                              bottom: 24,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if ((banner.title ?? "")
                                                      .isNotEmpty)
                                                    Text(
                                                      banner.title!,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.white,
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            height: 1.15,
                                                          ),
                                                    ),
                                                  if ((banner.description ?? "")
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 8,
                                                          ),
                                                      child: Text(
                                                        banner.description!,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.92,
                                                                  ),
                                                              fontSize: 12.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      "Order Fresh Today",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: const Color(
                                                              0xFF9A4D16,
                                                            ),
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight.w700,
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
                                  Positioned(
                                    bottom: 12,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        authCtrl.banners.length,
                                        (i) => Obx(() {
                                          final isActive =
                                              authCtrl.currentIndex.value == i;
                                          return AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 320,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            width: isActive ? 24 : 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              gradient: isActive
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color(0xFFFFF176),
                                                        Color(0xFFFFA726),
                                                      ],
                                                    )
                                                  : null,
                                              color: isActive
                                                  ? null
                                                  : Colors.white.withOpacity(
                                                      0.42,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    _animatedEntry(
                      delayMs: 260,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "Snacks & Drinks",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3C2918),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${authCtrl.quickCategories.length} categories",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFAF6528),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _animatedEntry(
                      delayMs: 340,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Obx(() {
                          final snackDrinkCategories = authCtrl.quickCategories;

                          if (authCtrl.isQuickCategoryLoading.value &&
                              snackDrinkCategories.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (snackDrinkCategories.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                "Quick categories are not available right now",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7A6759),
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: snackDrinkCategories.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final item = entry.value;
                                final gradientColors = [
                                  const Color(0xFFB55D1E),
                                  const Color(0xFFE29140),
                                ];

                                return TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 500 + (index * 80),
                                  ),
                                  curve: Curves.easeOutCubic,
                                  builder: (_, value, __) {
                                    return Transform.translate(
                                      offset: Offset(0, 12 * (1 - value)),
                                      child: Opacity(
                                        opacity: value.clamp(0, 1),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          onTap: () => _openCategoryMenu(item),
                                          child: Container(
                                            width: 94,
                                            margin: const EdgeInsets.only(
                                              right: 14,
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: 78,
                                                  height: 78,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: gradientColors,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: gradientColors
                                                            .first
                                                            .withOpacity(0.30),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          2.3,
                                                        ),
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                      child: ClipOval(
                                                        child: Image.network(
                                                          item.categoryImage ??
                                                              "",
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                _,
                                                                __,
                                                                ___,
                                                              ) => Image.asset(
                                                                "assets/images/popular.png",
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item.name ?? "",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF4B321D,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _animatedEntry(
                      delayMs: 420,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "Popular Dishes",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3C2918),
                              ),
                            ),
                            const Spacer(),
                            // InkWell(
                            //   onTap: () =>
                            //       Get.to(() => const MenuEntryScreen()),
                            //   child: Text(
                            //     "See All",
                            //     style: GoogleFonts.poppins(
                            //       fontSize: 13,
                            //       fontWeight: FontWeight.w700,
                            //       color: const Color(0xFFAF6528),
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(width: 4),
                            // const Icon(
                            //   Icons.arrow_forward_ios,
                            //   size: 14,
                            //   color: Color(0xFFAF6528),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(() {
                        if (authCtrl.isSnackDrinkItemsLoading.value) {
                          return popularDishShimmer();
                        }

                        if (authCtrl.snackDrinkItems.isEmpty) {
                          return const Center(child: Text("No items found"));
                        }

                        return Column(
                          children: authCtrl.snackDrinkItems
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final dish = entry.value;
                                return _animatedEntry(
                                  delayMs: 420 + (index * 90),
                                  duration: const Duration(milliseconds: 460),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 7),
                                    child: popularDishFullCard(
                                      image: dish.menuImage?.isNotEmpty == true
                                          ? dish.menuImage ?? ""
                                          : "assets/images/popular.png",
                                      name: dish.name ?? "Unknown",
                                      description:
                                          dish.description?.isNotEmpty == true
                                          ? dish.description!
                                          : "Delight in every bite",
                                      rating: dish.isAvailable == true
                                          ? "4.5"
                                          : "0.0",
                                      category: dish.isVeg == true
                                          ? "Veg"
                                          : "Non-Veg",
                                      time:
                                          dish.subCategory?.name?.isNotEmpty ==
                                              true
                                          ? dish.subCategory!.name!
                                          : "Freshly prepared",
                                      price: "Rs ${dish.basePrice ?? 0}",
                                      onAdd: () {
                                        openProductBottomSheet(context, {
                                          "id": dish.sId ?? "",
                                          "name": dish.name ?? "",
                                          "desc": dish.description ?? "",
                                          "price": "Rs ${dish.basePrice ?? 0}",
                                          "image": dish.menuImage ?? "",
                                        });
                                      },
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
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

Widget bannerShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
  final bool isVeg = category.toLowerCase().contains("veg");
  final List<Color> accent = isVeg
      ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
      : [const Color(0xFFC62828), const Color(0xFFEF5350)];

  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFFFF6EE)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.orange.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: image.startsWith("http")
                  ? Image.network(
                      image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/popular.png",
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.58), Colors.transparent],
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 9,
                      color: isVeg ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isVeg ? "Veg" : "Non-Veg",
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD369), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  price,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D1D1F),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 11),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: accent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isVeg ? "Healthy choice" : "Chef special",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.background],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "ADD +",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
}
