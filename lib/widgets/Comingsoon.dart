import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taste_of_bihar/utils/app_color.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgStart,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final glowShift = (_controller.value - 0.5) * 80;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.bgStart,
                  AppColors.primary,
                  AppColors.background,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  right: -50 + glowShift,
                  child: _glowBubble(
                    size: 180,
                    colors: [
                      Colors.white.withOpacity(0.22),
                      AppColors.background.withOpacity(0.08),
                    ],
                  ),
                ),
                Positioned(
                  top: size.height * 0.28,
                  left: -60 - glowShift,
                  child: _glowBubble(
                    size: 220,
                    colors: [
                      const Color(0xFFFFD59E).withOpacity(0.18),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -70,
                  right: 20 + glowShift,
                  child: _glowBubble(
                    size: 200,
                    colors: [
                      const Color(0xFFFFA34D).withOpacity(0.24),
                      AppColors.primary.withOpacity(0.06),
                    ],
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 24),
                        _PartyCard(
                          title: 'Birthday Party',
                          category: 'Popular Choice',
                          subtitle: 'Cake table, decor, curated menu',
                          description:
                              'Celebrate with a premium setup, warm lighting, signature food platters, and a lively dining experience for your guests.',
                          icon: Icons.cake_rounded,
                          gradient: const [
                            Color(0xFFFF8A65),
                            Color(0xFFFFB74D),
                          ],
                          highlights: const [
                            'Custom decoration',
                            'Family seating',
                            'Photo-ready backdrop',
                          ],
                          animationValue: _controller.value,
                          delay: 0.0,
                        ),
                        const SizedBox(height: 18),
                        _PartyCard(
                          title: 'Kitti Party',
                          category: 'Ladies Event',
                          subtitle: 'Elegant table styling, snacks, fun vibes',
                          description:
                              'Host a polished kitty party with themed seating, handcrafted bites, refreshing beverages, and a stylish social setting.',
                          icon: Icons.local_bar_rounded,
                          gradient: const [
                            Color(0xFFFF5F9E),
                            Color(0xFFFF9068),
                          ],
                          highlights: const [
                            'Group package',
                            'Mocktail service',
                            'Music ambience',
                          ],
                          animationValue: _controller.value,
                          delay: 0.22,
                        ),
                        const SizedBox(height: 18),
                        _PartyCard(
                          title: 'Anniversary Party',
                          category: 'Elegant Celebration',
                          subtitle:
                              'Romantic decor, premium dining, soft music',
                          description:
                              'Create a graceful anniversary evening with intimate table decor, chef-crafted dishes, ambient lighting, and a refined celebration setup.',
                          icon: Icons.favorite_rounded,
                          gradient: const [
                            Color(0xFF7B61FF),
                            Color(0xFFFF7AA2),
                          ],
                          highlights: const [
                            'Candle light setup',
                            'Couple special table',
                            'Dessert presentation',
                          ],
                          animationValue: _controller.value,
                          delay: 0.44,
                        ),
                        const SizedBox(height: 22),
                        _buildBottomBanner(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.20),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.16),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFFFE2C2),
                ),
                child: Text(
                  'Party Specials',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Plan memorable parties with Taste of Bihar',
            style: GoogleFonts.poppins(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choose your event style and create a premium celebration experience with our signature food and curated ambience.',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: Colors.white.withOpacity(0.88),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroInfoChip(Icons.groups_rounded, '10-80 Guests'),
              const SizedBox(width: 10),
              _heroInfoChip(Icons.restaurant_menu_rounded, 'Custom Menu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4E6), Color(0xFFFFE3C4)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.background.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Decor, dining, and celebration in one place',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Contact the team to reserve a polished party setup for your next event.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppColors.primary.withOpacity(0.78),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.background],
              ),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroInfoChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD08A), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowBubble({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.highlights,
    required this.animationValue,
    required this.delay,
  });

  final String title;
  final String category;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final List<String> highlights;
  final double animationValue;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final wave = math.sin((animationValue + delay) * math.pi * 2);
    final translateY = wave * 6;

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.96),
              Colors.white.withOpacity(0.90),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(colors: gradient),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              gradient.first.withOpacity(0.22),
                              gradient.last.withOpacity(0.18),
                            ],
                          ),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: AppColors.primary.withOpacity(0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradient.first.withOpacity(0.18),
                    gradient.last.withOpacity(0.10),
                  ],
                ),
              ),
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.6,
                  color: const Color(0xFF314154),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: highlights
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xFFF7F2EB),
                      ),
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: const Color(0xFFF9F5EF),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Custom menu and decor available',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(colors: gradient),
                    ),
                    child: Text(
                      'Book Now',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
