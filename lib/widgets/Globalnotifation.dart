import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';

class GlobalNotificationService {
  static void show({
    required String title,
    required String message,
    Color bgColor = Colors.green,
  }) {
    /// 🔔 NORMAL NOTIFICATION SOUND ONLY
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      volume: 1.0,
      looping: false,
    );

    /// 🔔 UI SNACKBAR
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
