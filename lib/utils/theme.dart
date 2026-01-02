import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/utils/app_color.dart';

class AppTheme {
  static final appTheme = ThemeData(
    primaryColor: AppColors.primary,

    scaffoldBackgroundColor: const Color(0xFFFFFCF6),
    brightness: Brightness.light,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.white,
    ),

    textTheme: GoogleFonts.nunitoSansTextTheme().apply(),
    primaryTextTheme: GoogleFonts.nunitoSansTextTheme().apply(),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  );
}
