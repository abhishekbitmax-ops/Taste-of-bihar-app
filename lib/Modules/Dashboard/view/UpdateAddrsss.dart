import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/model/Dashboardmodel.dart';

class Updateaddrsss extends StatefulWidget {
  final String addressId;

  const Updateaddrsss({super.key, required this.addressId});

  @override
  State<Updateaddrsss> createState() => _UpdateaddrsssState();
}

class _UpdateaddrsssState extends State<Updateaddrsss> {
  final Authcontroller ctrl = Get.find<Authcontroller>();

  final TextEditingController streetCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController zipCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();

  String selectedLabel = "Home";
  bool isDefault = false;
  bool _isPrefilled = true;

  @override
  void initState() {
    super.initState();

    if (ctrl.addressList.isEmpty) {
      ctrl.fetchAddresses().then((_) => _bindFromList());
    } else {
      _bindFromList();
    }
  }

  void _bindFromList() {
    final AddressData? adr = ctrl.getAddressById(widget.addressId);

    if (adr == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Address not found")));
      return;
    }

    streetCtrl.text = adr.street ?? '';
    areaCtrl.text = adr.area ?? '';
    cityCtrl.text = adr.city ?? '';
    stateCtrl.text = adr.state ?? '';
    zipCtrl.text = adr.zipCode ?? '';
    landmarkCtrl.text = adr.landmark ?? '';

    selectedLabel = adr.label ?? "Home";
    isDefault = adr.isDefault ?? false;

    _isPrefilled = true; // 👈 important
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Update Address",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _input(streetCtrl, "House No / Street / Road *"),
            _input(areaCtrl, "Area *"),
            _input(cityCtrl, "City *"),
            _input(stateCtrl, "State *"),
            _input(zipCtrl, "Pincode *", keyboard: TextInputType.number),
            _input(landmarkCtrl, "Landmark (Optional)"),

            const SizedBox(height: 20),

            Text(
              "Address Label",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["Home", "Work", "Other"].map((label) {
                final isSelected = selectedLabel == label;
                return InkWell(
                  onTap: () => setState(() => selectedLabel = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                      ),
                      color: isSelected
                          ? Colors.green.shade50
                          : Colors.transparent,
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.green : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isDefault,
              title: const Text("Set as default address"),
              onChanged: (v) => setState(() => isDefault = v),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isLoading.value
                      ? null
                      : () async {
                          final success = await ctrl.updateAddressApi(
                            addressId: widget.addressId,
                            label: selectedLabel,
                            street: streetCtrl.text.trim(),
                            area: areaCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            state: stateCtrl.text.trim(),
                            zipCode: zipCtrl.text.trim(),
                            landmark: landmarkCtrl.text.trim(),
                            isDefault: isDefault,
                          );

                          if (!mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Address updated successfully"),
                              ),
                            );
                            Get.back(); // ⬅ return to previous screen
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to update address"),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                  ),
                  child: ctrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "UPDATE ADDRESS",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    bool isPrefilled = controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus && isPrefilled) {
            controller.clear(); // 🔥 clear on first tap
            isPrefilled = false;
            setState(() {});
          }
        },
        child: TextField(
          controller: controller,
          keyboardType: keyboard,
          style: TextStyle(color: isPrefilled ? Colors.grey : Colors.black),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
