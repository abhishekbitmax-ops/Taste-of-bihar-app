import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final Authcontroller otpCtrl = Get.find<Authcontroller>();

  final TextEditingController otpInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 🔥 SHOW OTP IN TOP SNACKBAR (DEV MODE)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      final otp = args?["otp"];

      if (otp != null && otp.toString().isNotEmpty) {
        Get.snackbar(
          "DEV OTP",
          "Your OTP is $otp",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 7),
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          icon: const Icon(Icons.lock, color: Colors.white),
        );

        // (optional) auto-fill OTP field
        otpInputCtrl.text = otp.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Get.arguments['mobile']; // passed mobile number

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, size: 22),
                        ),
                      ),
                    ),
                    Text(
                      "Otp Verification",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  "Taste of Bihar",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),

                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.2,
                      child: Image.asset(
                        "assets/images/logo_tob.png",
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // OTP Input
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: otpInputCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 6,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "Enter OTP",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () => SizedBox(
                    width: 260,
                    child: ElevatedButton(
                      onPressed: otpCtrl.isLoading.value
                          ? null
                          : () async {
                              String mobile = Get.arguments["mobile"];
                              String otp = otpInputCtrl.text.trim();

                              await otpCtrl.verifyOtp(mobile: mobile, otp: otp);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: otpCtrl.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Verify OTP",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const Spacer(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
