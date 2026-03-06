import 'package:flutter/material.dart';
import 'package:taste_of_bihar/utils/app_color.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';

const String razorpayKey = "rzp_test_RqyfR6ogB6XV65";

class PaymentBottomSheet extends StatefulWidget {
  final num amount; // rupees (for UI)
  const PaymentBottomSheet({super.key, required this.amount});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final CartController ctrl = Get.find<CartController>();
  late Razorpay _razorpay;
  bool isPaying = false;
  bool paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
  }

  @override
  void dispose() {
    try {
      _razorpay.clear();
    } catch (_) {}
    super.dispose();
  }

  /// 🔥 PAY NOW FLOW
  Future<void> openCheckout() async {
    if (isPaying) return;

    try {
      setState(() => isPaying = true);

      /// 👉 STEP 1: PLACE ORDER (UPI)
      await ctrl.placeOrder(
        addressId: ctrl.selectedAddressId.value,
        paymentMethod: "ONLINE",
      );

      /// 👉 STEP 2: CHECK RAZORPAY ORDER ID
      if (ctrl.razorpayOrderId.value.isEmpty) {
        setState(() => isPaying = false);
        Get.snackbar("Error", "Unable to initiate payment");
        return;
      }

      /// 👉 STEP 3: OPEN RAZORPAY
      _razorpay.open({
        'key': razorpayKey,
        'amount': (widget.amount * 100).round(), // paise
        'currency': 'INR',
        'order_id': ctrl.razorpayOrderId.value,
        'name': 'Resto Grandma',
        'description': 'Food Order Payment',
        'retry': {
          'enabled': false, // 🔥 STOP retry popup
        },
        'theme': {'color': '#8B0000'},
      });
    } catch (e) {
      setState(() => isPaying = false);
      Get.snackbar("Error", "Payment initiation failed");
    }
  }

  /// ✅ PAYMENT SUCCESS
  void _handleSuccess(PaymentSuccessResponse response) {
    paymentCompleted = true; // 🔥 IMPORTANT

    _razorpay.clear(); // 🔥 STOP all further callbacks

    Get.back(); // close dialog

    ctrl.verifyPayment(
      razorpayOrderId: response.orderId!,
      razorpayPaymentId: response.paymentId!,
      razorpaySignature: response.signature!,
    );
  }

  /// ❌ PAYMENT FAILED / CANCELLED
  void _handleError(PaymentFailureResponse response) {
    if (paymentCompleted) {
      // 🔥 Payment already success, ignore fake error
      return;
    }

    setState(() => isPaying = false);

    Get.snackbar("Payment Failed", response.message ?? "Payment cancelled");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment, size: 36, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              "Confirm Payment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "₹${widget.amount}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            /// PAY BUTTON
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isPaying ? null : openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isPaying
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      )
                    : const Text(
                        "Pay Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            /// CANCEL
            TextButton(
              onPressed: () {
                setState(() => isPaying = false);
                Get.back();
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
