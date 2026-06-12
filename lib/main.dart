import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latest_jk/choosegame.dart';
import 'package:latest_jk/splashscreen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latest_jk/yantra%20history%20controller.dart';
import 'ChooseGameController.dart';
import 'authentication.dart';

/// Makes every dart:io HttpClient (used by the `http` package and
/// CachedNetworkImage) trust the bundled ISRG Root X1 root in ADDITION to the
/// device's system roots. The site's Let's Encrypt certificate chains to
/// ISRG Root X1, which is missing from the trust store of older Android devices
/// (pre-7.1.1) now that Let's Encrypt no longer cross-signs to the old DST Root
/// CA X3 — that is the cause of "CERTIFICATE_VERIFY_FAILED: unable to get local
/// issuer certificate" on those phones. This adds the real root (NOT an
/// accept-all bypass), so validation stays secure on every device.
class _AppHttpOverrides extends HttpOverrides {
  final SecurityContext _context;
  _AppHttpOverrides(this._context);

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(_context);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Build a security context that keeps the system roots and adds ISRG Root X1.
  final securityContext = SecurityContext(withTrustedRoots: true);
  try {
    final certBytes = await rootBundle.load('assets/certs/isrgrootx1.pem');
    securityContext.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
  } on TlsException {
    // Already trusted on this device (newer Android) -> nothing to add.
  } catch (_) {
    // Asset missing/unreadable -> fall back to system roots only.
  }
  HttpOverrides.global = _AppHttpOverrides(securityContext);

  await GetStorage.init();  // Initialize GetStorage
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the AuthController
    Get.put(AuthController());
    Get.put(YantraHistoryController()); // Initialize the history controller
   // Get.put(ResultController()); // Initialize the result controller
    Get.put(ChooseGameController());

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)), // Optional splash delay
        builder: (context, snapshot) {
          // Check login status and redirect accordingly
          final authController = Get.find<AuthController>();
          return authController.isLoggedIn ? ChooseGame(username: '',) : SplashScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}