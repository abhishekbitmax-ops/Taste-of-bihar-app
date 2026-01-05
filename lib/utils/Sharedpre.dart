import 'package:shared_preferences/shared_preferences.dart';

class SharedPre {
  static const String KEY_MOBILE = "user_mobile";

  // Save verified mobile
  static Future<void> saveMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_MOBILE, mobile);
  }

  // Get saved mobile
  static Future<String> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_MOBILE) ?? "";
  }

  // Optional: clear mobile
  static Future<void> clearMobile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_MOBILE);
  }
}
