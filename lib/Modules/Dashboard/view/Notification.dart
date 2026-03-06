import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/Modules/Navbar/navbar.dart'; // 👈 your bottom nav

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final CartController ctrl = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: ctrl.fetchNotifications,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 200),
                Center(child: Text("No notifications found")),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.fetchNotifications,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: ctrl.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final n = ctrl.notifications[index];
              final payload = n.data;

              return InkWell(
                onTap: () {
                  /// ✅ MARK AS READ
                  if (n.isRead != true && n.id != null) {
                    ctrl.markNotificationAsRead(n.id!);
                  }

                  /// 🍽️ DAILY MENU CLICK → GO TO MENU TAB (INDEX 2)
                  if (payload?.type == "DAILY_MENU") {
                    Get.offAll(() => BottomNavBar(initialIndex: 2));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: n.isRead == true
                        ? null
                        : LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.blue.shade100.withOpacity(0.35),
                            ],
                          ),
                    color: n.isRead == true ? Colors.white : null,
                    border: Border.all(
                      color: n.isRead == true
                          ? Colors.grey.shade200
                          : Colors.blue.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔵 ICON + UNREAD DOT
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade100,
                            ),
                            child: Icon(
                              _iconByType(n.type),
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          if (n.isRead == false)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // 📄 CONTENT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title ?? "",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),

                            if (n.message != null)
                              Text(
                                n.message!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade800,
                                ),
                              ),

                            // 🍽️ DAILY MENU CARD
                            if (payload?.type == "DAILY_MENU") ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (payload?.image != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        payload!.image!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payload?.name ?? "",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "₹${payload?.price ?? ""}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // 🔐 OTP
                            if (payload?.otp != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  "OTP: ${payload!.otp}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  IconData _iconByType(String? type) {
    switch (type) {
      case "DELIVERY_OTP":
        return Icons.lock_outline;
      case "ORDER_CONFIRMATION":
        return Icons.check_circle_outline;
      case "DAILY_MENU":
        return Icons.restaurant_menu;
      default:
        return Icons.notifications_none;
    }
  }
}
