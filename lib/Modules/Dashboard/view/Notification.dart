import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/Modules/Navbar/cartcontroller.dart';
import 'package:taste_of_bihar/Modules/Navbar/navbar.dart';
import 'package:taste_of_bihar/utils/app_color.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final CartController ctrl = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, Color(0xFFF4A53B)],
            ),
          ),
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
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 120),
                Icon(
                  Icons.notifications_active_outlined,
                  size: 72,
                  color: Colors.orange.shade300,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'No notifications yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Pull down to refresh and check for new updates.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.fetchNotifications,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ctrl.unreadCount} unread',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total ${ctrl.notifications.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: ctrl.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = ctrl.notifications[index];
                    final payload = n.data;
                    final palette = _paletteByType(n.type ?? payload?.type);

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        if (n.isRead != true && n.id != null) {
                          ctrl.markNotificationAsRead(n.id!);
                        }

                        if (payload?.type == 'DAILY_MENU') {
                          Get.offAll(() => BottomNavBar(initialIndex: 2));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              palette.light,
                              palette.light.withOpacity(0.6),
                            ],
                          ),
                          border: Border.all(
                            color: n.isRead == true
                                ? Colors.white
                                : palette.main.withOpacity(0.28),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: palette.main.withOpacity(0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: palette.main.withOpacity(0.18),
                                      ),
                                      child: Icon(
                                        _iconByType(n.type ?? payload?.type),
                                        size: 18,
                                        color: palette.dark,
                                      ),
                                    ),
                                    if (n.isRead != true)
                                      Positioned(
                                        right: -1,
                                        top: -1,
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: palette.dark,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title ?? 'Notification',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatTime(n.createdAt),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if ((n.message ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                n.message!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  height: 1.4,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                            if (payload?.type == 'DAILY_MENU') ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.72),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: (payload?.image ?? '').isNotEmpty
                                          ? Image.network(
                                              payload!.image!,
                                              width: 52,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    width: 52,
                                                    height: 52,
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.restaurant_menu,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              width: 52,
                                              height: 52,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.restaurant_menu,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payload?.name ?? "Today's special",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Rs. ${payload?.price ?? '-'}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if ((payload?.otp ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: palette.main.withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  'Delivery OTP: ${payload!.otp}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: palette.dark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData _iconByType(String? type) {
    switch (type) {
      case 'DELIVERY_OTP':
        return Icons.lock_outline;
      case 'ORDER_CONFIRMATION':
        return Icons.check_circle_outline;
      case 'DAILY_MENU':
        return Icons.restaurant_menu;
      default:
        return Icons.notifications_none;
    }
  }

  _NotificationPalette _paletteByType(String? type) {
    switch (type) {
      case 'DELIVERY_OTP':
        return const _NotificationPalette(
          main: Color(0xFF2F80ED),
          light: Color(0xFFEAF3FF),
          dark: Color(0xFF1F5CAD),
        );
      case 'ORDER_CONFIRMATION':
        return const _NotificationPalette(
          main: Color(0xFF23A36A),
          light: Color(0xFFEAFBF3),
          dark: Color(0xFF15724A),
        );
      case 'DAILY_MENU':
        return const _NotificationPalette(
          main: Color(0xFFEF7E0C),
          light: Color(0xFFFFF3E5),
          dark: Color(0xFFB85800),
        );
      default:
        return const _NotificationPalette(
          main: Color(0xFF7A7F8A),
          light: Color(0xFFF1F3F6),
          dark: Color(0xFF4B4F57),
        );
    }
  }

  String _formatTime(DateTime? createdAt) {
    if (createdAt == null) return 'Just now';

    final difference = DateTime.now().difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    if (difference.inDays < 7) return '${difference.inDays} day ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class _NotificationPalette {
  final Color main;
  final Color light;
  final Color dark;

  const _NotificationPalette({
    required this.main,
    required this.light,
    required this.dark,
  });
}
