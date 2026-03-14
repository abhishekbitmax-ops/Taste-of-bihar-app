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

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    IconData icon,
    String title, {
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accentColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.black54,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _quickCard(
    IconData icon,
    String title,
    String subtitle, {
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.20),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11.2,
                color: Colors.white.withOpacity(0.88),
              ),
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
          colors: [Color(0xFFFF5A36), Color(0xFFFF8A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A3D).withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
            title: Text(
              'Profile',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 19,
              ),
            ),
          ),
          bottomNavigationBar: ZomatoCartBar(),
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.softLight,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFBF5), Color(0xFFF7F1E4), Color(0xFFFCE7D2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                color: AppColors.primary,
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
                                      const Color(0xFFFF8A3D),
                                      0.35 + (0.12 * t),
                                    ) ??
                                    AppColors.primary;
                                final bottomColor =
                                    Color.lerp(
                                      const Color(0xFF213C63),
                                      const Color(0xFFFFB347),
                                      0.38 + (0.14 * t),
                                    ) ??
                                    AppColors.primary;

                                return Container(
                                  height: 23.h,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(36),
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
                                padding: EdgeInsets.fromLTRB(5.w, 1.2.h, 5.w, 1.2.h),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your Profile',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(0.88),
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Taste of Bihar',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () => Get.to(() => const EditProfileScreen()),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.18),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.18),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 1.h),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.14),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.95),
                                                    width: 2.2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.10),
                                                      blurRadius: 14,
                                                      offset: const Offset(0, 6),
                                                    ),
                                                  ],
                                                ),
                                                child: CircleAvatar(
                                                  radius: 27,
                                                  backgroundColor: const Color(0xFFFFE0B2),
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
                                                          size: 26,
                                                          color: AppColors.primary,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                              SizedBox(width: 3.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      user.name ?? 'No Name',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      user.email ?? 'xyz@example.com',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11.5,
                                                        color: Colors.white.withOpacity(0.86),
                                                      ),
                                                    ),
                                                    SizedBox(height: 0.6.h),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 9,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFFE4B5),
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      child: Text(
                                                        'Premium Member',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 10.2,
                                                          color: AppColors.primary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -18),
                          child: _buildSectionTransition(
                            start: 0.28,
                            end: 0.60,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.08),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _infoChip(Icons.person_outline, 'Profile', 'Active'),
                                    _verticalDivider(),
                                    _infoChip(Icons.location_on_outlined, 'Address', 'Saved'),
                                    _verticalDivider(),
                                    _infoChip(Icons.verified_outlined, 'Status', 'Member'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _sectionTitle(
                          'Quick Access',
                          'Manage your orders and delivery preferences',
                        ),
                        const SizedBox(height: 14),
                        _buildSectionTransition(
                          start: 0.34,
                          end: 0.65,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                            child: GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.16,
                              children: [
                                _quickCard(
                                  Icons.shopping_bag_outlined,
                                  'My Orders',
                                  'Track and review your recent orders',
                                  colors: const [Color(0xFF355C7D), Color(0xFF6C5B7B)],
                                  onTap: () => Get.to(OrderHistoryScreen()),
                                ),
                                _quickCard(
                                  Icons.location_on_outlined,
                                  'My Addresses',
                                  'Manage saved delivery locations',
                                  colors: const [Color(0xFFFF8A3D), Color(0xFFFFC15E)],
                                  onTap: () => Get.bottomSheet(
                                    const AddressSelector(heightFactor: 1),
                                    isScrollControlled: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTransition(
                          start: 0.5,
                          end: 0.82,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(
                                'Account & Support',
                                'Useful links and settings for your account',
                              ),
                              const SizedBox(height: 14),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                                child: Column(
                                  children: [
                                    _menuTile(
                                      Icons.help_outline,
                                      'Help & Support',
                                      accentColor: const Color(0xFF4F7CFF),
                                      onTap: () => Get.to(PrivacyPolicyScreen()),
                                    ),
                                    _menuTile(
                                      Icons.restaurant_menu,
                                      'Partner with Us',
                                      accentColor: const Color(0xFFFF8A3D),
                                      onTap: () => openRatingDialog(context),
                                    ),
                                    _menuTile(
                                      Icons.lock_outline,
                                      'Privacy Policy',
                                      accentColor: const Color(0xFF16A085),
                                      onTap: () => Get.to(PrivacyPolicyScreen()),
                                    ),
                                    _menuTile(
                                      Icons.description_outlined,
                                      'Terms & Conditions',
                                      accentColor: const Color(0xFF8E44AD),
                                      onTap: () => Get.to(PrivacyPolicyScreen()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                                  backgroundColor: Colors.white,
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
                                        style: TextStyle(color: Colors.white),
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
                        const SizedBox(height: 22),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 34,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
