import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restro_app/Modules/Dashboard/view/Reviewbookingtable.dart';

class TableBookingFormScreen extends StatefulWidget {
  const TableBookingFormScreen({super.key});

  @override
  State<TableBookingFormScreen> createState() => _TableBookingFormScreenState();
}

class _TableBookingFormScreenState extends State<TableBookingFormScreen> {
  int selectedGuests = 2;
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      selectedGuests = Get.arguments as int; // 👈 value पकड़ ली
    }
  }

  final List<Map<String, String>> dates = [
    {"day": "Today", "date": "02 Jan"},
    {"day": "Tomorrow", "date": "03 Jan"},
    {"day": "Sunday", "date": "04 Jan"},
    {"day": "Monday", "date": "05 Jan"},
  ];

  final List<String> times = [
    "5:00 PM",
    "5:15 PM",
    "5:30 PM",
    "5:45 PM",
    "6:00 PM",
    "6:15 PM",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                      Positioned(
                        top: 2.h,
                        left: 4.w,
                        child: InkWell(
                          onTap: () => Get.back(),
                          borderRadius: BorderRadius.circular(50),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(0xFF8B0000),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      // TITLE
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Book a table",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B0000),
                              ),
                            ),
                            Text(
                              "Swaad of Grandma, Sector 43, Noida",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Color(0xFF8B0000),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // GUESTS SELECT
                      Text(
                        "Select number of guests",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$selectedGuests Guests",
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),

                            DropdownButton<int>(
                              underline: const SizedBox(),
                              value: selectedGuests, // 👈 FIX
                              items: List.generate(
                                30,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text("${i + 1}"),
                                ),
                              ),
                              onChanged: (v) => setState(
                                () => selectedGuests = v!,
                              ), // already correct
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // DATE SELECT
                      Text(
                        "Select date",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      SizedBox(
                        height: 10.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: dates.length,
                          itemBuilder: (_, i) {
                            bool selected = selectedDateIndex == i;
                            return InkWell(
                              onTap: () =>
                                  setState(() => selectedDateIndex = i),
                              child: Container(
                                width: 28.w,
                                margin: EdgeInsets.only(right: 3.w),
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.green.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.green.shade700
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dates[i]["day"]!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      dates[i]["date"]!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // OFFER BANNER
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_offer,
                              size: 18,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                "Flat 30% OFF offer slots available from Mon, 05 Jan, 12:00 PM",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // TIME SELECT
                      Text(
                        "Select time of day",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Color(0xFF8B0000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Lunch / Dinner Toggle
                      Row(
                        children: [
                          _toggleChip(
                            "Lunch",
                            selectedTimeIndex == 0,
                            () => setState(() => selectedTimeIndex = 0),
                          ),
                          SizedBox(width: 4.w),
                          _toggleChip(
                            "Dinner",
                            selectedTimeIndex == 1,
                            () => setState(() => selectedTimeIndex = 1),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // TIME SLOTS GRID
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: times.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 2.h,
                          childAspectRatio: 1.6,
                        ),
                        itemBuilder: (_, i) {
                          bool selected = selectedTimeIndex == i;
                          return InkWell(
                            onTap: () => setState(() => selectedTimeIndex = i),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? Colors.green.shade700
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    times[i],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "25% OFF",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // PROCEED BOTTOM BAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  elevation: 0, // flat look like Container
                ),
                onPressed: () {
                  Get.to(ReviewBookingScreen());
                },
                child: Text(
                  "Proceed",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _toggleChip(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.green.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.green.shade700 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
