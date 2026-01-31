import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    required this.restaurantId,
    required this.orderId,
    required this.deliveryPersonId,
    required this.foodItemId,
  });

  final String restaurantId;
  final String orderId;
  final String deliveryPersonId;
  final String foodItemId;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  final CartController ratingCtrl = Get.find<CartController>();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !ratingCtrl.isLoading.value, // ⛔ block back during submit
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Rate Your Experience",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // ⭐ STAR RATING
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        size: 34,
                        color: index < selectedRating
                            ? Colors.amber
                            : Colors.grey.shade400,
                      ),
                      onPressed: ratingCtrl.isLoading.value
                          ? null
                          : () {
                              setState(() => selectedRating = index + 1);
                            },
                    );
                  }),
                ),

                // ✍️ REVIEW
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Write your review (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: ratingCtrl.isLoading.value
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            selectedRating == 0 || ratingCtrl.isLoading.value
                            ? null
                            : () async {
                                final success = await ratingCtrl.submitRating(
                                  rating: selectedRating,
                                  comment: reviewController.text.trim(),
                                  restaurantId: widget.restaurantId,
                                  orderId: widget.orderId,
                                  deliveryPersonId: widget.deliveryPersonId,
                                  foodItemId: widget.foodItemId,
                                );

                                if (success && mounted) {
                                  Navigator.pop(context); // ✅ CLOSE AFTER API
                                }
                              },

                        child: ratingCtrl.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
