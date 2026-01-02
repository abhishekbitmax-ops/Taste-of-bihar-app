class ApiEndpoint {
  // 🌍 Base API URL (for all API requests)
  static const String baseUrl = "https://developer.bitmaxtest.com";

 

  //Patient App Endpoints

  // 🔹 AUTHENTICATION ENDPOINTS
  static const String register = "/api/register";
  static const String login = "/api/login";


  // 🧩 Helper — automatically combines base URL + endpoint
  static String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }

 
}
