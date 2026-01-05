import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Authcontroller loginCtrl = Get.put(Authcontroller());
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginbackr.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(
                    top: 150,
                  ), // 👈 is value ko badha/ghata kar niche adjust kar sakte ho
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    child: ClipOval(
                      child: Transform.scale(
                        scale: 1.25,
                        child: Image.asset(
                          "assets/images/dadi.png",
                          fit: BoxFit.cover,
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Grandmaa's Secret Taste",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),
                Text(
                  "Log In or Sign Up",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      TextField(
                        controller: loginCtrl.mobileCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Mobile Number",
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B0000),
                              width: 1.6,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_android,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Obx(
                        () => ElevatedButton(
                          onPressed: loginCtrl.isLoading.value
                              ? null
                              : loginCtrl.sendOtp,
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

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
