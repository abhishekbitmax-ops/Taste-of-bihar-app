import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/menuscreen.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:taste_of_bihar/widgets/Viewcartbar.dart';

class MenuEntryScreen extends StatelessWidget {
  const MenuEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      bottomNavigationBar: ZomatoCartBar(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Meal Timings',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F2A44), AppColors.primary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Food Available: 7 AM - 10 PM',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Delivery Time: 30 min',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.94),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _mealCard(
                title: 'Breakfast',
                servingTime: 'Morning time: 7 AM - 10 AM',
                deliveryTime: 'Night: 8 PM - 10 PM',
                colors: const [Color(0xFFFFA726), Color(0xFFFF7043)],
                icon: Icons.wb_sunny_outlined,
              ),
              const SizedBox(height: 12),
              _mealCard(
                title: 'Lunch',
                servingTime: 'Morning time: 7 AM - 12 AM',
                deliveryTime: 'Delivery: 12 PM - 1:30 PM',
                colors: const [Color(0xFF26A69A), Color(0xFF42A5F5)],
                icon: Icons.lunch_dining_outlined,
              ),
              const SizedBox(height: 12),
              _mealCard(
                title: 'Dinner',
                servingTime: 'Evening time: 4 PM - 6 PM',
                deliveryTime: 'Delivery: 8:30 PM - 12 PM',
                colors: const [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                icon: Icons.nightlight_round,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealCard({
    required String title,
    required String servingTime,
    required String deliveryTime,
    required List<Color> colors,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () => Get.to(() => const MenuScreen()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -18,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -10,
              bottom: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  servingTime,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  deliveryTime,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
