import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ReviewBookingScreen extends StatelessWidget {
  const ReviewBookingScreen({super.key});

  Widget _rowIconText(
    IconData icon,
    String text, {
    FontWeight? weight,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: weight ?? FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String price, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
        Text(
          price,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (_, __, ___) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // ✅ AppBar added
          backgroundColor: AppColors.primary,
          leading: IconButton(
            // ✅ Top-left back button
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "Review Booking Details", // ✅ Title text
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top notice banner
                        Container(
                          width: 92.w,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Cover charge of ₹50 will be adjusted with your final bill payment at the restaurant",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // Booking summary card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Review booking details",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2.h),

                                _rowIconText(
                                  Icons.calendar_today,
                                  "04 Jan at 12:00 PM",
                                  weight: FontWeight.w600,
                                ),
                                SizedBox(height: 1.2.h),
                                _rowIconText(Icons.person, "2 guests"),
                                SizedBox(height: 1.2.h),
                                _rowIconText(Icons.restaurant, "Miss Nora"),
                                Padding(
                                  padding: EdgeInsets.only(left: 6.w),
                                  child: Text(
                                    "Sector 43, Noida",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),

                                const Divider(height: 20, thickness: 0.6),
                                _rowIconText(
                                  Icons.local_offer,
                                  "Flat 25% OFF on total bill",
                                  color: Colors.green.shade700,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 6.w),
                                  child: Text(
                                    "Pay bill between 12:00 PM – 8:00 PM",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),

                                Text(
                                  "Cover charge to be paid",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),

                                _priceRow("Cover charge", "₹50", bold: true),
                                _priceRow("Discount", "-₹20"),
                                _priceRow(
                                  "Final cover charge",
                                  "₹30",
                                  bold: true,
                                ),

                                SizedBox(height: 3.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                        label: Text(
                                          "Add special request",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 1.2.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1.2,
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Guest Preferences
                        _sectionTitle("Guest Preferences"),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: _rowIconText(
                            Icons.check_circle,
                            "Modification available till 11:30 AM, 04 Jan",
                          ),
                        ),
                        SizedBox(height: 1.2.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: _rowIconText(
                            Icons.cancel,
                            "Cancellation available with 100% refund till 11:30 AM, 04 Jan",
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Your Details
                        _sectionTitle("Your Details"),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Abhishek",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Edit",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Terms & Conditions
                        _sectionTitle("Terms and Conditions"),
                        _bullet(
                          "Please arrive 15 minutes prior to your reservation time",
                        ),
                        _bullet(
                          "Internet handling fee will be applied during final bill payment",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Pay Bill bar
              Container(
                width: 100.w,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "₹50.00  TOTAL",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 1.2.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Pay bill",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

