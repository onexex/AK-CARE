class AppConfig {
  // Ang iyong Local IP Address
  static const String serverIP = "192.168.35.129"; 
  
  // Base URL (Base sa iyong folder name na 'akop_member')
  static const String baseUrl = "http://$serverIP/akop_member";
  
  // Endpoints para sa Login
  static const String checkUserUrl = "$baseUrl/check_user.php";
  static const String verifyOtpUrl = "$baseUrl/verify_otp.php";
  
  // Endpoints para sa Dashboard (I-prepare na natin)
  static const String getHistoryUrl = "$baseUrl/get_history.php";
  static const String getNewsUrl = "$baseUrl/get_news.php";
}