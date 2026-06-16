class AppConfig {
  AppConfig._();

  // ── Environment ──
  // Production: 'akopmember.anakalusugan.com.ph'
  // Local LAN:  '192.168.1.107'
  static const String _host = 'akopmember.anakalusugan.com.ph';

  // ── PHP Backend Path ──
  static const String _backendPath = 'api';

  // ── Base URL ──
  static const String baseUrl = 'http://$_host/$_backendPath';

  // ── Endpoints ──
  static const String checkUserUrl = '$baseUrl/check_user.php';
  static const String verifyOtpUrl = '$baseUrl/verify_otp.php';
  static const String getHistoryUrl = '$baseUrl/get_history.php';
  static const String getNewsUrl = '$baseUrl/get_news.php';

  // ── Timeout ──
  static const Duration apiTimeout = Duration(seconds: 10);
}
