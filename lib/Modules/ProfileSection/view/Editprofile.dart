import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/ProfileSection/Controller/profilecontroller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ctrl = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: ctrl.pickImage,
                child: Obx(
                  () => CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: ctrl.imageFile.value != null
                        ? FileImage(ctrl.imageFile.value!)
                        : null,
                    child: ctrl.imageFile.value == null
                        ? const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              buildTextField(
                "Name",
                TextField(
                  controller: ctrl.nameCtrl,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: ctrl.profileData.value.name ?? "Enter Name",
                  ),
                ),
              ),

              buildTextField(
                "Mobile",
                TextField(
                  controller: ctrl.mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Enter Mobile",
                  ),
                ),
              ),

              buildTextField(
                "Gender",
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: ctrl.selectedGender.value,
                    items: ctrl.genders
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) =>
                        ctrl.selectedGender.value = val ?? "male",
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText:
                          ctrl.profileData.value.gender ?? "Select Gender",
                    ),
                  ),
                ),
              ),

              buildTextField(
                "DOB",
                Obx(
                  () => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(
                          const Duration(days: 365 * 18),
                        ),
                        firstDate: DateTime(1970),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) ctrl.selectedDOB.value = picked;
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            ctrl.selectedDOB.value != null
                                ? "${ctrl.selectedDOB.value!.day}/${ctrl.selectedDOB.value!.month}/${ctrl.selectedDOB.value!.year}"
                                : "Select DOB",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ✍ Manual Address Field
              buildTextField(
                "Address",
                TextField(
                  controller: ctrl.addressCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter Address",
                    prefixIcon: Icon(
                      Icons.home,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                () => ElevatedButton(
                  onPressed: ctrl.isLoading.value
                      ? null
                      : () => ctrl.updateProfileApi(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: ctrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String title, Widget field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }
}
