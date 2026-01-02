import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restro_app/Modules/Dashboard/view/Booktableschedul.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        SizedBox(width: 1.w),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
        ),
      ],
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

  Widget _offerButton(String text, bool filled, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 1.4.h),
          decoration: BoxDecoration(
            color: filled ? Color(0xFF8B0000) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF8B0000), width: 1.5),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : Color(0xFF8B0000),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (_, __, ___) => Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE HEADER
              Stack(
                children: [
                  Image.asset(
                    "assets/images/delas.png",
                    width: 100.w,
                    height: 28.h,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 5.h,
                    left: 4.w,
                    child: _actionIcon(Icons.arrow_back, () => Get.back()),
                  ),
                  Positioned(
                    top: 5.h,
                    right: 4.w,
                    child: _actionIcon(Icons.share, () {}),
                  ),
                  Positioned(
                    bottom: 2.h,
                    left: 4.w,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "PRE-BOOK TABLE",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2.h,
                    right: 4.w,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "4.2",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // RESTAURANT NAME
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  "Swaad of Grandma's",
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 0.5.h),

              // ADDRESS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  "3rd Floor, Rcub Mall, Sector 43, Noida",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              // CHIPS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: _infoChip(Icons.schedule, "12:00 PM – 11:30 PM"),
              ),

              SizedBox(height: 1.2.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    _infoChip(Icons.location_on, "9.8 km"),
                    const Spacer(),
                    _infoChip(Icons.currency_rupee, "₹1900 for two"),
                  ],
                ),
              ),

              SizedBox(height: 2.5.h),

              // CASHBACK BANNER
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 92.w,
                    height: 7.h,
                    alignment: Alignment.center,
                    child: Text(
                      "10% Cashback on every dining bill",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // ACTION BUTTONS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    _offerButton("Book a Table", false, () {
                      Get.bottomSheet(
                        Container(
                          height: 40.h,
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select number of guests",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF8B0000),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Icon(
                                          Icons.close,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),

                              SizedBox(
                                height: 7.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 30,
                                  itemBuilder: (_, i) {
                                    int guest = i + 1;
                                    return Container(
                                      width: 14.w,
                                      margin: EdgeInsets.only(right: 3.w),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$guest",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 4.h),

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF8B0000),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () =>
                                      Get.to(TableBookingFormScreen()),
                                  child: Text(
                                    "Continue",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // OFFER TABS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    _tab("Pre-book offers", true),
                    SizedBox(width: 5.w),
                    _tab("Walk-in offers", false),
                    SizedBox(width: 5.w),
                    _tab("Menu", false),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // OFFERS SECTION
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  "Pre-book offers",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: 1.h),

              _offerTile("10% Cashback on dining bill"),
              _offerTile("Flat 25% OFF on pre-booking"),
              _offerTile("Free dessert on orders above ₹1500"),
              _offerTile("Special seat decoration available"),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, bool selected) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.green.shade700 : Colors.black54,
      ),
    );
  }

  Widget _offerTile(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      child: Row(
        children: [
          const Icon(Icons.local_offer, size: 16, color: Colors.green),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
