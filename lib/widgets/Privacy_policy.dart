import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Privacy Policy"),
            _paragraph(
              "Your privacy is important to us. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our mobile application.",
            ),

            _section("1. Information We Collect"),
            _bullet(
              "Personal details such as name, phone number, and address.",
            ),
            _bullet(
              "Order details including items ordered and delivery location.",
            ),
            _bullet(
              "Payment-related information (we do not store card details).",
            ),
            _bullet("Device and usage information for app performance."),

            _section("2. How We Use Your Information"),
            _bullet("To process and deliver your orders."),
            _bullet("To communicate order updates and notifications."),
            _bullet("To improve our app, services, and user experience."),
            _bullet("To comply with legal and regulatory requirements."),

            _section("3. Sharing of Information"),
            _paragraph(
              "We do not sell or rent your personal information. Your data may be shared only with trusted partners such as delivery personnel and payment gateways strictly for order fulfillment.",
            ),

            _section("4. Data Security"),
            _paragraph(
              "We use reasonable security measures to protect your personal data from unauthorized access, misuse, or disclosure.",
            ),

            _section("5. Cookies & Tracking"),
            _paragraph(
              "We may use cookies or similar technologies to enhance your experience and analyze app usage.",
            ),

            _section("6. Your Rights"),
            _bullet("You can review or update your personal information."),
            _bullet("You may request deletion of your account and data."),
            _bullet("You can opt out of promotional communications."),

            _section("7. Changes to This Policy"),
            _paragraph(
              "We may update this Privacy Policy from time to time. Any changes will be reflected on this page.",
            ),

            _section("8. Contact Us"),
            _paragraph(
              "If you have any questions or concerns regarding this Privacy Policy, please contact us at:",
            ),
            const SizedBox(height: 6),
            Text(
              "📧 support@yourapp.com\n📞 +91-XXXXXXXXXX",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------- UI HELPERS ----------

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.black54,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
