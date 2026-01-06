import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/utils/Sharedpre.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  double _lastKeyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;

    /// 🔥 Keyboard CLOSED → scroll back to top
    if (_lastKeyboardHeight > 0 && bottomInset == 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    _lastKeyboardHeight = bottomInset;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            /// 🔥 BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                "assets/images/loginbackr.png",
                fit: BoxFit.cover,
              ),
            ),

            /// 🔥 FULL SCROLLABLE CONTENT
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    /// 🔥 HEADER
                    Container(
                      padding: const EdgeInsets.only(top: 270, bottom: 30),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white24,
                            child: ClipOval(
                              child: Image.asset(
                                "assets/images/applogo.png",
                                fit: BoxFit.cover,
                                width: 130,
                                height: 130,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Grandmaa's Secret Tastes",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 25),

                          /// 🔥 TAB BAR
                          Container(
                            width: 260,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: TabBar(
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorPadding: const EdgeInsets.all(4),
                              indicator: BoxDecoration(
                                color: const Color(0xFF8B0000),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black87,
                              labelStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                              tabs: const [
                                Tab(text: "User Login"),
                                Tab(text: "Admin"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// 🔥 TAB CONTENT
                    SizedBox(
                      height: 360,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [_UserLoginTab(), _AdminTab()],
                      ),
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
}

/* ================= USER LOGIN TAB ================= */
class _UserLoginTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Authcontroller loginCtrl = Get.put(Authcontroller());
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          32,
          30,
          32,
          bottomInset > 0 ? bottomInset + 20 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: loginCtrl.mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter Mobile Number",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: const Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 22),
            Obx(
              () => ElevatedButton(
                onPressed: loginCtrl.isLoading.value
                    ? null
                    : () async {
                        final savedMobile = await SharedPre.getMobile();

                        if (savedMobile.isNotEmpty) {
                          loginCtrl.mobileLogin();
                        } else {
                          loginCtrl.sendOtp();
                        }
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: loginCtrl.isLoading.value
                    ? const CircularProgressIndicator()
                    : Text(
                        "Continue Securely",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= ADMIN TAB ================= */
class _AdminTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              "Admin Panel Access",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final Uri url = Uri.parse(
                  'https://restro-83kb.vercel.app/login',
                );
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Open Admin Panel",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
