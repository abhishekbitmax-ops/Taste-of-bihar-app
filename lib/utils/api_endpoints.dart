class ApiEndpoint {
  //  Base API URL (for all API requests)
  static const String baseUrl = "https://sog.bitmaxtest.com/api/v1/user";

  // Patient App Endpoints
  static const String baseUrl2 = "https://sog.bitmaxtest.com/api/v1";
  //  AUTHENTICATION ENDPOINTS

  static const String login = "/mobile-send-otp";
  static String verifyOtp = "/mobile-verify-otp";
  static const String basicDetails = "/mobile-register";
  static const String profile = "/profile";
  static const String updateProfile = "/profile-update";
  static const String categories = "/categories";
  static const String Addtocart = "/cart/items";
  static const String getCart = "/cart";
  static const String addAddress = "/address";
  static const String GetAddress = "/address";
  static const String ClearCart = "/cart/clear";
  static const String ApplyCoupan = "/cart/coupon";
  static const String Orderhistorycard = "/order/history";
  static const String Orderplace = "/order/place";
  static const String PaymentVerify = "/payment/verify";
  static const String GetBanners = "/banners/active";
  static const String PopluarDishs = "/order/popular";
  static const String GetCoupancode = "/coupons/active";
  static const String Getnotifaction = "/notifications";
  static const String Ratingreview = "/rating/submit";
  static const String SelectAddress = "/cart/select-address";

  //  Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }

  static String getUrl2(String endpoint) {
    return "$baseUrl2$endpoint";
  }
}
