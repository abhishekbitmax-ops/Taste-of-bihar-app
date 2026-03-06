import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Auth/controller/AuthController.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final Authcontroller addressCtrl = Get.find<Authcontroller>();

  String selectedLabel = "Home";
  bool isDefault = true;

  final TextEditingController streetCtrl = TextEditingController();
  final TextEditingController areaCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController zipCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          "Add Address",
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
            _input(streetCtrl, " House No /Street / Road *"),
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
                final bool isSelected = selectedLabel == label;
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
              activeColor: Colors.green,
              title: const Text("Set as default address"),
              onChanged: (val) {
                setState(() => isDefault = val);
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: addressCtrl.isLoading.value
                      ? null
                      : () {
                          addressCtrl.street.value = streetCtrl.text;
                          addressCtrl.area.value = areaCtrl.text;
                          addressCtrl.city.value = cityCtrl.text;
                          addressCtrl.state.value = stateCtrl.text;
                          addressCtrl.zipCode.value = zipCtrl.text;

                          addressCtrl.addAddressApi(
                            label: selectedLabel,
                            landmark: landmarkCtrl.text,
                            isDefault: isDefault,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: addressCtrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "SAVE ADDRESS",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
