import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Full immersive screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E0E00), Color(0xFF1F1C18)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.hourglass_bottom,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            Text(
              "Coming Soon",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // SUBTITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "We’re working hard to bring you something amazing.\nStay tuned!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),
            ),

            const SizedBox(height: 40),

            // PROGRESS INDICATOR
            SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
              ),
            ),

            const SizedBox(height: 60),

            // FOOTER TEXT
            Text(
              "Launching Soon 🚀",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
