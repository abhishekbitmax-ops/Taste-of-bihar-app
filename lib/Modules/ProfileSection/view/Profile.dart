import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:taste_of_bihar/Modules/Auth/view/Login.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/OrderHistory.dart';
import 'package:taste_of_bihar/Modules/ProfileSection/Controller/profilecontroller.dart';
import 'package:taste_of_bihar/Modules/ProfileSection/view/Editprofile.dart';
import 'package:taste_of_bihar/utils/Sharedpre.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:taste_of_bihar/widgets/Addressbottomsheet.dart';
import 'package:taste_of_bihar/widgets/Privacy_policy.dart';
import 'package:taste_of_bihar/widgets/Rating_and_review.dart';
import 'package:taste_of_bihar/widgets/Viewcartbar.dart';

class ProfileHomeScreen extends StatefulWidget {
  ProfileHomeScreen({super.key});

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen>
    with TickerProviderStateMixin {
  final ProfileController profileCtrl = Get.put(ProfileController());

  late final AnimationController _entryController;
  late final AnimationController _gradientController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _headerFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    _entryController.forward();
    _gradientController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void openRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => RatingDialog(
        restaurantId: 'RESTAURANT_ID_HERE',
        orderId: 'ORDER_ID_HERE',
        deliveryPersonId: 'DELIVERY_PERSON_ID_HERE',
        foodItemId: 'FOOD_ITEM_ID_HERE',
      ),
    );
  }

  Future<void> _onRefresh() async {
    await profileCtrl.fetchProfile();
  }

  Widget _buildSectionTransition({
    required Widget child,
    required double start,
    required double end,
  }) {
    final animation = CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black54,
      ),
      onTap: onTap,
    );
  }

  Widget _quickCard(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientButton(String label, {VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.background,
          ),
        ),
      ),
    );
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
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: AppColors.primary,
              statusBarIconBrightness: Brightness.light,
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
            title: const Text(
              'Profile',
              style: TextStyle(color: AppColors.background),
            ),
          ),
          bottomNavigationBar: ZomatoCartBar(),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Obx(() {
                  final user = profileCtrl.profileData.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _headerFade,
                        child: SlideTransition(
                          position: _headerSlide,
                          child: AnimatedBuilder(
                            animation: _gradientController,
                            builder: (context, child) {
                              final t = _gradientController.value;
                              final topColor =
                                  Color.lerp(
                                    AppColors.primary,
                                    AppColors.badgecolor,
                                    0.22 + (0.18 * t),
                                  ) ??
                                  AppColors.primary;
                              final bottomColor =
                                  Color.lerp(
                                    AppColors.primary,
                                    AppColors.background,
                                    0.30 + (0.20 * t),
                                  ) ??
                                  AppColors.primary;

                              return Container(
                                height: 28.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(32),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [topColor, bottomColor],
                                    begin: Alignment(-1 + (2 * t), -1),
                                    end: Alignment(1 - (2 * t), 1),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                5.w,
                                1.6.h,
                                5.w,
                                2.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () =>
                                          Get.to(() => EditProfileScreen()),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.background
                                              .withOpacity(0.22),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 38,
                                        backgroundColor: AppColors.background,
                                        backgroundImage:
                                            (user.profile != null &&
                                                user.profile!.isNotEmpty)
                                            ? NetworkImage(user.profile!)
                                            : null,
                                        onBackgroundImageError:
                                            (user.profile != null &&
                                                user.profile!.isNotEmpty)
                                            ? (_, __) {}
                                            : null,
                                        child:
                                            (user.profile == null ||
                                                user.profile!.isEmpty)
                                            ? const Icon(
                                                Icons.person,
                                                size: 36,
                                                color: Colors.black54,
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              user.name ?? 'No Name',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 0.3.h),
                                            Text(
                                              user.email ?? 'xyz@example.com',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.background
                                                    .withOpacity(0.18),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                'Taste Of Bihar Member',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.black87,

                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      _buildSectionTransition(
                        start: 0.34,
                        end: 0.65,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.6,
                            children: [
                              _quickCard(
                                Icons.shopping_bag,
                                'My Orders',
                                'View your order history',
                                onTap: () => Get.to(OrderHistoryScreen()),
                              ),
                              _quickCard(
                                Icons.location_on,
                                'My Addresses',
                                'Saved delivery locations',
                                onTap: () => Get.bottomSheet(
                                  const AddressSelector(heightFactor: 1),
                                  isScrollControlled: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildSectionTransition(
                        start: 0.5,
                        end: 0.82,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _menuTile(
                                Icons.help_outline,
                                'Help & Support',
                                onTap: () => Get.to(PrivacyPolicyScreen()),
                              ),
                              _menuTile(
                                Icons.restaurant,
                                'Partner with Us',
                                onTap: () => openRatingDialog(context),
                              ),

                              const Divider(),
                              _menuTile(
                                Icons.lock,
                                'Privacy Policy',
                                onTap: () => Get.to(PrivacyPolicyScreen()),
                              ),
                              _menuTile(
                                Icons.description,
                                'Terms & Conditions',
                                onTap: () => Get.to(PrivacyPolicyScreen()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTransition(
                        start: 0.7,
                        end: 1.0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: _gradientButton(
                            'Log Out',
                            onTap: () {
                              Get.defaultDialog(
                                title: 'Confirm Logout',
                                middleText: 'Are you sure you want to log out?',
                                backgroundColor: AppColors.background,
                                radius: 12,
                                titleStyle: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                middleTextStyle: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                confirm: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Get.back();
                                    await SharedPre.clearAll();
                                    Get.offAll(() => const LoginScreen());
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: AppColors.background,
                                      ),
                                    ),
                                  ),
                                ),
                                cancel: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Get.back(),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
