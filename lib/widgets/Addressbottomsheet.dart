import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/view/CurrentMapfetch.dart';
import 'package:restro_app/Modules/Dashboard/view/UpdateAddrsss.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/utils/Sharedpre.dart';

class AddressSelector extends StatelessWidget {
  final double heightFactor; // 0.5 = half sheet, 1 = full screen

  const AddressSelector({super.key, this.heightFactor = 1});

  @override
  Widget build(BuildContext context) {
    final CartController cartCtrl = Get.find<CartController>();
    final Authcontroller addressCtrl = Get.find<Authcontroller>();

    // 🔥 Bottom sheet open होते ही fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addressCtrl.fetchAddresses();
    });

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
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
            onTap: () => Get.to(() => DeliveryLocationScreen()),
            leading: const Icon(Icons.add, size: 26, color: Color(0xFF8B0000)),
            title: Text(
              "Add New Address",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B0000),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black45,
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          const Divider(),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Saved Addresses",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (addressCtrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (addressCtrl.addressList.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await addressCtrl.fetchAddresses();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text("No Address Found")),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await addressCtrl.fetchAddresses();
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: addressCtrl.addressList.length,
                  itemBuilder: (_, i) {
                    final adr = addressCtrl.addressList[i];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        onTap: () async {
                          cartCtrl.selectedAddress.value =
                              "${adr.street}, ${adr.area}, ${adr.city}";

                          cartCtrl.selectedAddressId.value = adr.id ?? "";
                          await SharedPre.saveSelectedAddressId(adr.id ?? "");

                          Get.back();
                        },

                        leading: Icon(
                          adr.label == "Home"
                              ? Icons.home_outlined
                              : adr.label == "Work"
                              ? Icons.work_outline
                              : Icons.location_on_outlined,
                          size: 26,
                          color: const Color(0xFF555555),
                        ),

                        title: Row(
                          children: [
                            Text(
                              adr.label ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (cartCtrl.selectedAddress.value ==
                                "${adr.street}, ${adr.area}, ${adr.city}")
                              const Text(
                                "Selected",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),

                        subtitle: Text(
                          "${adr.street}, ${adr.landmark}, ${adr.area}, ${adr.city}, ${adr.state}, ${adr.zipCode}",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),

                        // 🔥 EDIT + DELETE ICONS BACK
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✏️ EDIT
                            InkWell(
                              onTap: () {
                                if (adr.id == null) return;
                                Get.to(() => Updateaddrsss(addressId: adr.id!));
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 🗑 DELETE
                            InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                  title: "Delete Address",
                                  middleText:
                                      "Are you sure you want to delete this address?",
                                  textConfirm: "Delete",
                                  textCancel: "Cancel",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    Get.back();
                                    await addressCtrl.deleteAddress(adr.id!);
                                    await addressCtrl
                                        .fetchAddresses(); // 🔄 refresh
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),

                        dense: true,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
