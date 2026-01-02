import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/view/basicdetails.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late String otpCode;

  // Generate 6 digit OTP
  String _generateOTP() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // Show OTP in snackbar
  void _showOTP() {
    Get.snackbar(
      "Your OTP Code",
      otpCode,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4), // 👈 OTP will show for 4 sec
      backgroundColor: Colors.red.shade900,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      // fontSize: 18,
      isDismissible: true,
    );
  }

  @override
  void initState() {
    super.initState();
    otpCode = _generateOTP();
    Future.delayed(
      const Duration(milliseconds: 300),
      _showOTP,
    ); // 👈 show when screen opens
  }

  @override
  Widget build(BuildContext context) {
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
                      "Otp Verification page",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  "Swaad of Grandmaa",
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
                        "assets/images/dadi.png",
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
                      hintText: "••••••",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF8B0000),
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Verify Button
                SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const UserBasicDetails());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      "Verify OTP",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Resend OTP
                TextButton(
                  onPressed: () {
                    otpCode = _generateOTP(); // regenerate new OTP
                    _showOTP(); // 👈 show new OTP in snackbar
                  },
                  child: Text(
                    "Didn't receive? Resend OTP",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
