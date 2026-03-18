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
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        if (n.isRead != true && n.id != null) {
                          ctrl.markNotificationAsRead(n.id!);
                        }

                        if (payload?.type == 'DAILY_MENU') {
                          Get.offAll(() => BottomNavBar(initialIndex: 2));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: n.isRead == true
                                ? Colors.grey.shade200
                                : palette.main.withOpacity(0.32),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: palette.light,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _iconByType(n.type ?? payload?.type),
                                    size: 14,
                                    color: palette.dark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _typeLabel(n.type ?? payload?.type),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: palette.dark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: palette.light,
                                  ),
                                  child: Icon(
                                    _iconByType(n.type ?? payload?.type),
                                    size: 22,
                                    color: palette.dark,
                                  ),
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
                                          fontSize: 14,
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
                                if (n.isRead != true)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: palette.main,
                                      boxShadow: [
                                        BoxShadow(
                                          color: palette.main.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if ((n.message ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                n.message!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Colors.black.withOpacity(0.72),
                                ),
                              ),
                            ],
                            if (payload?.type == 'DAILY_MENU') ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: palette.light.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: palette.main.withOpacity(0.12),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: (payload?.image ?? '').isNotEmpty
                                          ? Image.network(
                                              payload!.image!,
                                              width: 72,
                                              height: 72,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    width: 72,
                                                    height: 72,
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.restaurant_menu,
                                                    ),
                                                  ),
                                            )
                                          : Container(
                                              width: 72,
                                              height: 72,
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _buildInfoChip(
                                                label: _formatPrice(
                                                  payload?.price,
                                                ),
                                                textColor: Colors.green.shade800,
                                                backgroundColor: Colors.white,
                                                borderColor:
                                                    Colors.green.shade100,
                                                icon: Icons.currency_rupee,
                                              ),
                                              if ((payload?.foodType ?? '')
                                                  .trim()
                                                  .isNotEmpty)
                                                _buildInfoChip(
                                                  label:
                                                      payload!.foodType!.toUpperCase(),
                                                  textColor: palette.dark,
                                                  backgroundColor:
                                                      Colors.white,
                                                  borderColor:
                                                      palette.main.withOpacity(
                                                    0.14,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if ((payload?.description ?? '')
                                              .trim()
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              payload!.description!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                height: 1.45,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
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
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.light,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: palette.main.withOpacity(0.18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.pin_outlined,
                                      size: 16,
                                      color: palette.dark,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Delivery OTP: ${payload!.otp}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: palette.dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if ((payload?.type != 'DAILY_MENU') &&
                                (payload?.otp ?? '').isEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.touch_app_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tap to view details',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
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
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'DELIVERY_OTP':
        return 'Delivery Update';
      case 'ORDER_CONFIRMATION':
        return 'Order Update';
      case 'DAILY_MENU':
        return 'New Item';
      default:
        return 'Alert';
    }
  }

  String _formatPrice(num? price) {
    if (price == null) return 'Price not available';
    final isWhole = price % 1 == 0;
    return isWhole ? '₹${price.toInt()}' : '₹${price.toStringAsFixed(2)}';
  }

  Widget _buildInfoChip({
    required String label,
    required Color textColor,
    required Color backgroundColor,
    required Color borderColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
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
