import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/menuscreen.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:taste_of_bihar/widgets/Viewcartbar.dart';

class MenuEntryScreen extends StatefulWidget {
  const MenuEntryScreen({super.key});

  @override
  State<MenuEntryScreen> createState() => _MenuEntryScreenState();
}

class _MenuEntryScreenState extends State<MenuEntryScreen> {
  final Authcontroller authCtrl = Get.find<Authcontroller>();

  bool _isSnackOrDrinkCategory(String name) {
    final normalized = name.trim().toLowerCase();
    return normalized.contains("snack") ||
        normalized.contains("drink") ||
        normalized.contains("beverage");
  }

  bool _isEventCategory(String name) {
    final normalized = name.trim().toLowerCase();
    return normalized == "event" || normalized == "events";
  }

  String _formatTime(String? value) {
    if ((value ?? "").isEmpty) return "";

    final parts = value!.split(":");
    if (parts.length != 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;

    final suffix = hour >= 12 ? "PM" : "AM";
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    final normalizedMinute = minute.toString().padLeft(2, '0');
    return "$normalizedHour:$normalizedMinute $suffix";
  }

  String _timeRange(String? start, String? end) {
    if ((start ?? "").isEmpty || (end ?? "").isEmpty) {
      return "Not available";
    }
    return "${_formatTime(start)} - ${_formatTime(end)}";
  }

  @override
  void initState() {
    super.initState();
    if (authCtrl.categories.isEmpty) {
      authCtrl.fetchCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      bottomNavigationBar: ZomatoCartBar(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Menu Categories',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final categories = authCtrl.categories
              .where(
                (category) =>
                    !_isSnackOrDrinkCategory(category.name ?? "") &&
                    !_isEventCategory(category.name ?? ""),
              )
              .toList();
          final isLoading = authCtrl.isCategoryLoading.value;

          return RefreshIndicator(
            onRefresh: authCtrl.fetchCategories,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Icons.restaurant_menu,
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
                                'Choose Your Favorite Category',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Food available 7 AM - 10 PM',
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
                  const SizedBox(height: 18),
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Text(
                          'No categories available',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      itemCount: categories.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isEventCard = _isEventCategory(
                          category.name ?? "",
                        );

                        return InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            Get.to(
                              () => const MenuScreen(),
                              arguments: {
                                "categoryName": category.name ?? "",
                                "categoryId": category.sId ?? "",
                                "orderStartTime": category.orderStartTime ?? "",
                                "orderEndTime": category.orderEndTime ?? "",
                                "deliveryStartTime":
                                    category.deliveryStartTime ?? "",
                                "deliveryEndTime":
                                    category.deliveryEndTime ?? "",
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: index.isEven
                                    ? const [
                                        Color(0xFFFFA726),
                                        Color(0xFFFF7043),
                                      ]
                                    : const [
                                        Color(0xFF26A69A),
                                        Color(0xFF42A5F5),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.network(
                                    category.categoryImage ?? "",
                                    width: 108,
                                    height: 108,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      "assets/images/popular.png",
                                      width: 108,
                                      height: 108,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        category.description?.isNotEmpty == true
                                            ? category.description!
                                            : "Browse available dishes by category",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.92),
                                          height: 1.45,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (!isEventCard) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.16,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Order Time: ${_timeRange(category.orderStartTime, category.orderEndTime)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Delivery Time: ${_timeRange(category.deliveryStartTime, category.deliveryEndTime)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                      Row(
                                        children: [
                                          Text(
                                            isEventCard
                                                ? 'View Events'
                                                : 'View Menu',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
