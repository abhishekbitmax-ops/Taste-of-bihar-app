import 'package:restro_app/Modules/Auth/view/Login.dart';
import 'package:restro_app/Modules/Dashboard/view/OrderHistory.dart';
import 'package:restro_app/Modules/ProfileSection/Controller/profilecontroller.dart';
import 'package:restro_app/Modules/ProfileSection/view/Editprofile.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:restro_app/utils/api_endpoints.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/services.dart';

import 'package:restro_app/widgets/Addressbottomsheet.dart';
import 'package:restro_app/widgets/OrderConfrimscreen.dart';
import 'package:restro_app/widgets/Privacy_policy.dart';
import 'package:restro_app/widgets/Viewcartbar.dart';

class ProfileHomeScreen extends StatelessWidget {
  ProfileHomeScreen({super.key});

  final ProfileController profileCtrl = Get.put(ProfileController());

  Widget _menuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8B0000)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF8B0000), size: 22),
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
          colors: [Color(0xFF8B0000), Color(0xFFE53935)],
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await profileCtrl.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8B0000),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Color(0xFFB71C1C),
              statusBarIconBrightness: Brightness.light,
            ),
            backgroundColor: const Color(0xFFB71C1C),
            elevation: 0,
            title: const Text("Profile", style: TextStyle(color: Colors.white)),
          ),

          bottomNavigationBar: ZomatoCartBar(),
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey.shade50,
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
                      // HEADER
                      Stack(
                        children: [
                          Container(
                            height: 26.h,
                            width: 100.w,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFB71C1C), Color(0xFFFF5252)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 18),
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.white,
                                    backgroundImage:
                                        (user.profile != null &&
                                            user.profile!.isNotEmpty)
                                        ? NetworkImage(user.profile!)
                                        : null,

                                    // ✅ ERROR HANDLER ONLY WHEN IMAGE EXISTS
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
                                            size: 35,
                                            color: Colors.black54,
                                          )
                                        : null,
                                  ),

                                  const SizedBox(height: 10),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.name ?? "No Name ",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          user.email ?? "xyz@example.com",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ✏ EDIT PROFILE ICON (TOP RIGHT)
                          Positioned(
                            top: 10,
                            right: 40,
                            child: InkWell(
                              onTap: () => Get.to(
                                () => EditProfileScreen(),
                              ), // 👈 Navigation
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // QUICK ACTIONS
                      Padding(
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
                              "My Orders",
                              "View your order history",
                              onTap: () => Get.to(OrderHistoryScreen()),
                            ),

                            _quickCard(
                              Icons.location_on,
                              "My Addresses",
                              "Saved delivery locations",
                              onTap: () => Get.bottomSheet(
                                const AddressSelector(heightFactor: 1),
                                isScrollControlled: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // MENU LIST
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _menuTile(
                              Icons.help_outline,
                              "Help & Support",
                              onTap: () => Get.to(PrivacyPolicyScreen()),
                            ),
                            _menuTile(Icons.restaurant, "Partner with Us"),
                            _menuTile(Icons.card_membership, "Pro Membership"),
                            const Divider(),
                            _menuTile(
                              Icons.lock,
                              "Privacy Policy",
                              onTap: () => Get.to(PrivacyPolicyScreen()),
                            ),
                            _menuTile(
                              Icons.description,
                              "Terms & Conditions",
                              onTap: () => Get.to(PrivacyPolicyScreen()),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // LOGOUT BUTTON
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: _gradientButton(
                          "Log Out",
                          onTap: () async {
                            await SharedPre.clearAll();
                            Get.offAll(() => const LoginScreen());
                          },
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
