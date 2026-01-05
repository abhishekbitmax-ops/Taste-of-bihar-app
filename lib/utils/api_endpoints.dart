class ApiEndpoint {
  //  Base API URL (for all API requests)
  static const String baseUrl =
      "https://resto-grandma.onrender.com/api/v1/user";

  // Patient App Endpoints

  //  AUTHENTICATION ENDPOINTS

  static const String login = "/mobile-send-otp";
  static const String verifyOtp = "/mobile-verify-otp";
  static const String basicDetails = "/mobile-register";
  static const String profile = "/profile";
  static const String mobileLogin = "/mobile-login";
  static const String mobileLoginVerify = "/mobile-login-verify";

  //  Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }
}
