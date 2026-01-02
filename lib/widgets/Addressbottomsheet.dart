import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restro_app/Modules/Dashboard/view/CurrentMapfetch.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

class AddressSelector extends StatelessWidget {
  final double heightFactor; // 0.5 = half sheet, 1 = full screen

  const AddressSelector({super.key, this.heightFactor = 0.5});

  @override
  Widget build(BuildContext context) {
    final CartController cartCtrl = Get.find<CartController>();

    final List<Map<String, dynamic>> savedAddress = const [
      {
        "title": "Home",
        "address": "8th floor, Tower-C, Bhutani Alphathum, Sector 90, Noida",
        "icon": Icons.home_outlined,
      },
      {
        "title": "Work",
        "address": "B41 b-block, Noida sec-63, Sector 63, Noida",
        "icon": Icons.work_outline,
      },
      {
        "title": "Other",
        "address": "Raj Homes near Hathi Mandir, Sector 66, Mamura, Noida",
        "icon": Icons.location_on_outlined,
      },
    ];

    return Container(
      height: 100.h * heightFactor, // responsive sizer height
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Select Address",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, size: 22, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListTile(
            onTap: () => Get.to(() => SelectLocationScreen()),
            leading: const Icon(Icons.add, size: 26, color: Color(0xFF8B0000)),
            title: Text("Add New Address",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8B0000))),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Saved Addresses", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: savedAddress.length,
              itemBuilder: (_, i) {
                final adr = savedAddress[i];
                return Obx(
                  () => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: ListTile(
                      onTap: () => cartCtrl.selectedAddress.value = adr["address"],
                      leading: Icon(adr["icon"], size: 26, color: const Color(0xFF555555)),
                      title: Row(
                        children: [
                          Text(adr["title"], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          if (cartCtrl.selectedAddress.value == adr["address"])
                            const Text("Selected", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      subtitle: Text(adr["address"], style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.pink),
                      dense: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
