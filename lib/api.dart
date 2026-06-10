/// Central place for the backend base URL and URL building.
///
/// Use [Api.getUrl] everywhere instead of hardcoding full URLs, e.g.:
///   Uri.parse(Api.getUrl('Application/user_login.php'))
///   Api.getUrl(item['image'].toString())   // -> https://jkdeluxonline.com/images/...
///
/// To point the whole app at a different server, change [baseUrl] only.
class Api {
  Api._();

  /// Production backend. (The old demo host demojkd.balajitechbiz.com served
  /// the same data; the live site is jkdeluxonline.com.)
  static const String baseUrl = 'https://jkdeluxonline.com';

  /// Returns an absolute URL for [path] under [baseUrl].
  /// Accepts API endpoints ('Application/result.php?username=x') or asset
  /// paths ('images/jkimg/1.png'); a leading '/' is tolerated.
  static String getUrl(String path) {
    if (path.isEmpty) return baseUrl;
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleaned';
  }
}
