/// Central place for the backend base URL and URL building.
///
/// Use [Api.getUrl] everywhere instead of hardcoding full URLs, e.g.:
///   Uri.parse(Api.getUrl('Application/user_login.php'))
///   Api.getUrl(item['image'].toString())   // -> https://jkdeluxonline.com/images/...
///
/// To point the whole app at a different server, change [baseUrl] only.
class Api {
  Api._();

  /// Production backend. (Earlier hosts: demojkd.balajitechbiz.com served the
  /// same data; jkdeluxonline.com is a sibling deployment on the same cPanel/DB.
  /// The live API for this app is abconlinetrading.com/Application/.)
  static const String baseUrl = 'https://abconlinetrading.com';

  /// Returns an absolute URL for [path] under [baseUrl].
  /// Accepts API endpoints ('Application/result.php?username=x') or asset
  /// paths ('images/jkimg/1.png'); a leading '/' is tolerated.
  static String getUrl(String path) {
    if (path.isEmpty) return baseUrl;
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleaned';
  }
}
