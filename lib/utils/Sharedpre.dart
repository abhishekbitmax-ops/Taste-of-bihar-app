import 'package:shared_preferences/shared_preferences.dart';

class SharedPre {
  static const String KEY_MOBILE = "user_mobile";
  static const String KEY_ACCESS_TOKEN = "access_token";
  static const String KEY_REFRESH_TOKEN = "refresh_token";
  static const String KEY_EXPIRES_IN = "expires_in";
  static const String KEY_CART_CATEGORY_NAME = "cart_category_name";
  static const String KEY_CART_ORDER_START_TIME = "cart_order_start_time";
  static const String KEY_CART_ORDER_END_TIME = "cart_order_end_time";
  static const String KEY_CART_DELIVERY_START_TIME = "cart_delivery_start_time";
  static const String KEY_CART_DELIVERY_END_TIME = "cart_delivery_end_time";

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

  // Save Tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_ACCESS_TOKEN, accessToken);
    await prefs.setString(KEY_REFRESH_TOKEN, refreshToken);
    await prefs.setString(KEY_EXPIRES_IN, expiresIn);
  }

  // Get Access Token
  static Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_ACCESS_TOKEN) ?? "";
  }

  // Get Refresh Token
  static Future<String> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_REFRESH_TOKEN) ?? "";
  }

  // Get Expiry
  static Future<String> getExpiresIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_EXPIRES_IN) ?? "";
  }

  // Clear mobile + tokens (Logout use case)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_MOBILE);
    await prefs.remove(KEY_ACCESS_TOKEN);
    await prefs.remove(KEY_REFRESH_TOKEN);
    await prefs.remove(KEY_EXPIRES_IN);
  }

  // SAVE SELECTED ADDRESS ID
  static Future<void> saveSelectedAddressId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_address_id", id);
  }

  // GET SELECTED ADDRESS ID
  static Future<String> getSelectedAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("selected_address_id") ?? "";
  }

  static Future<void> saveCartTiming({
    required String categoryName,
    required String orderStartTime,
    required String orderEndTime,
    required String deliveryStartTime,
    required String deliveryEndTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_CART_CATEGORY_NAME, categoryName);
    await prefs.setString(KEY_CART_ORDER_START_TIME, orderStartTime);
    await prefs.setString(KEY_CART_ORDER_END_TIME, orderEndTime);
    await prefs.setString(KEY_CART_DELIVERY_START_TIME, deliveryStartTime);
    await prefs.setString(KEY_CART_DELIVERY_END_TIME, deliveryEndTime);
  }

  static Future<Map<String, String>> getCartTiming() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "categoryName": prefs.getString(KEY_CART_CATEGORY_NAME) ?? "",
      "orderStartTime": prefs.getString(KEY_CART_ORDER_START_TIME) ?? "",
      "orderEndTime": prefs.getString(KEY_CART_ORDER_END_TIME) ?? "",
      "deliveryStartTime": prefs.getString(KEY_CART_DELIVERY_START_TIME) ?? "",
      "deliveryEndTime": prefs.getString(KEY_CART_DELIVERY_END_TIME) ?? "",
    };
  }

  static Future<void> clearCartTiming() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_CART_CATEGORY_NAME);
    await prefs.remove(KEY_CART_ORDER_START_TIME);
    await prefs.remove(KEY_CART_ORDER_END_TIME);
    await prefs.remove(KEY_CART_DELIVERY_START_TIME);
    await prefs.remove(KEY_CART_DELIVERY_END_TIME);
  }
}
