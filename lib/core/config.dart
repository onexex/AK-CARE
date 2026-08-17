class AppConfig {
  AppConfig._();

  // ── Environment ──
  // Production: 'akopmember.anakalusugan.com.ph' with _backendPath 'api'
  // Local LAN:  '192.168.35.129'                 with _backendPath 'akop_member'
  // Local USB:  'localhost:8080'                 with _backendPath 'akop_member'
  //
  // On USB, requiring:
  //     adb reverse tcp:8080 tcp:80
  // which does not survive an unplug or a device reboot — re-run it when the
  // app suddenly cannot connect.
  //
  // Two traps on this machine. Laravel Herd's nginx binds 127.0.0.1:80 more
  // specifically than Apache's wildcard, so while Herd runs, loopback — and
  // therefore this tunnel — reaches Herd's 404 page instead of XAMPP. Herd must
  // be stopped, or Apache given a port of its own (httpd.conf has Listen 8081
  // for that, active after an Apache restart; then tunnel to 8081).
  //
  // The LAN option is preferred when it works, but the handset and this laptop
  // currently sit on the same subnet with no route between them.
  static const String _host = 'localhost:8080';

  // ── PHP Backend Path ──
  static const String _backendPath = 'akop_member';

  // ── Base URL ──
  static const String baseUrl = 'http://$_host/$_backendPath';

  // ── Endpoints ──
  // Deliberately none. Every screen names its endpoint through Api, which is
  // what carries the token, the timeout, the JSON handling, the 401 sign-out
  // and the one seam tests have. A ready-made full URL here is an invitation
  // to reach for `http` directly and miss all five — which is exactly how the
  // sign-in, news and pharmacy screens each came to be untestable.

  // ── Timeout ──
  static const Duration apiTimeout = Duration(seconds: 10);
}
