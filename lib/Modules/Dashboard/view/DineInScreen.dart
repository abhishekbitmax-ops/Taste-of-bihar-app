import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/services.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/tablecard.dart';
import 'package:taste_of_bihar/widgets/Viewcartbar.dart';

class Dineinscreen extends StatelessWidget {
  const Dineinscreen({super.key});
  Widget _moodCard(String title, String asset, IconData fallbackIcon) {
    return InkWell(
      onTap: () {
        Get.to(() => const PreBookMenuScreen()); // स्क्रीन खुलेगा
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(2, 2),
              color: Colors.grey.shade200,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: Image.asset(
                  asset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(fallbackIcon, size: 28, color: Colors.black38),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          bottomNavigationBar: ZomatoCartBar(),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(22),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.menu,
                            size: 26,
                            color: AppColors.primary,
                          ),
                          Text(
                            "Taste of Bihar",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 26,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // LOCATION BAR
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Bhutani Alphathum - Blossom County, Noida",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // BANNER SLIDER (Replaced Chips)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: const BannerSlider(),
                    ),

                    SizedBox(height: 3.h),

                    // MOOD TITLE
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        "What are you in the mood for?",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    // MOOD GRID
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.45,
                        children: [
                          _moodCard(
                            "Romantic Dining",
                            "assets/images/romantic.jpg",
                            Icons.person,
                          ),
                          _moodCard(
                            "Premium Dining",
                            "assets/images/premium.jpg",
                            Icons.person,
                          ),
                          _moodCard(
                            "Outdoor Dining",
                            "assets/images/outdoor.jpg",
                            Icons.person,
                          ),
                          _moodCard(
                            "Cozy Cafes",
                            "assets/images/cafe.jpg",
                            Icons.person,
                          ),
                          _moodCard(
                            "Family Dining",
                            "assets/images/family.jpg",
                            Icons.person,
                          ),
                          _moodCard(
                            "Buffet",
                            "assets/images/buffet.jpg",
                            Icons.person,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    SizedBox(height: 1.5.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "In The Limelight",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------ Banner Slider Widget ------------------

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageCtrl = PageController();
  int _current = 0;

  final List<String> banners = [
    "assets/images/dinein.png",
    "assets/images/dinein.png",
    "assets/images/dinein.png",
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: 92.w,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: banners.length,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                banners[i],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.person, size: 30)),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _current == i ? 22 : 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _current == i ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
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

