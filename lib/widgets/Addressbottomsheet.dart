import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/CurrentMapfetch.dart';
import 'package:taste_of_bihar/Modules/Dashboard/view/UpdateAddrsss.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/utils/Sharedpre.dart';
import 'package:taste_of_bihar/utils/app_color.dart';

class AddressSelector extends StatelessWidget {
  final double heightFactor;
  final bool selectionOnly;

  const AddressSelector({
    super.key,
    this.heightFactor = 1,
    this.selectionOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartCtrl = Get.find<CartController>();
    final Authcontroller addressCtrl = Get.find<Authcontroller>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      addressCtrl.fetchAddresses();
    });

    return Container(
      height: 100.h * heightFactor,
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
            leading: const Icon(Icons.add, size: 26, color: AppColors.primary),
            title: Text(
              "Add New Address",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
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
                  onRefresh: () async => addressCtrl.fetchAddresses(),
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
                onRefresh: () async => addressCtrl.fetchAddresses(),
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
                          final id = adr.id ?? "";
                          if (id.isEmpty) return;

                          if (selectionOnly) {
                            final fullAddress =
                                "${adr.street}, ${adr.landmark}, ${adr.area}, ${adr.city}, ${adr.state}, ${adr.zipCode}";

                            cartCtrl.selectedAddressId.value = id;
                            cartCtrl.selectedAddress.value = fullAddress;
                            await SharedPre.saveSelectedAddressId(id);

                            final success = await cartCtrl
                                .selectAddressAndUpdateBill(id);
                            if (success) {
                              Get.back();
                            }
                          } else {
                            Get.to(() => Updateaddrsss(addressId: id));
                          }
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
                            if (cartCtrl.selectedAddressId.value ==
                                (adr.id ?? ""))
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                if (adr.id == null) return;
                                Get.to(
                                  () => DeliveryLocationScreen(
                                    editAddressId: adr.id!,
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                    await addressCtrl.fetchAddresses();
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
