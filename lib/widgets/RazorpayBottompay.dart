import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

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

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout() {
    final int amountInPaise = (widget.amount * 100).round();

    if (ctrl.razorpayOrderId.value.isEmpty) {
      Get.snackbar("Error", "Invalid Razorpay order");
      return;
    }

    var options = {
      'key': razorpayKey,
      'amount': amountInPaise,
      'currency': 'INR',
      'order_id': ctrl.razorpayOrderId.value,
      'name': 'Resto Grandma',
      'description': 'Food Order Payment',
      'notes': {'backendOrderId': ctrl.orderId.value},
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#8B0000'},
    };

    _razorpay.open(options);
  }

  /// ✅ PAYMENT SUCCESS
  void _handleSuccess(PaymentSuccessResponse response) {
    Get.back(); // 🔥 CLOSE DIALOG

    ctrl.verifyPayment(
      razorpayOrderId: response.orderId!,
      razorpayPaymentId: response.paymentId!,
      razorpaySignature: response.signature!,
    );
  }

  void _handleError(PaymentFailureResponse response) {
    setState(() => isPaying = false);
    Get.snackbar("Payment Failed", response.message ?? "Payment cancelled");
  }

  void _handleWallet(ExternalWalletResponse response) {
    Get.snackbar("Wallet", response.walletName ?? "");
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
            // 💳 ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B0000).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.payment,
                color: Color(0xFF8B0000),
                size: 36,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Confirm Payment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              "Pay securely using UPI",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            // 💰 AMOUNT
            Text(
              "₹${widget.amount}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ PAY BUTTON
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: isPaying
                    ? null
                    : () {
                        setState(() => isPaying = true);
                        openCheckout();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isPaying
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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

            const SizedBox(height: 10),

            // ❌ CANCEL
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
