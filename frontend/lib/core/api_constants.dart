import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Backend server configuration.
///
/// Running on Laptop (Windows / Web / Mac / Linux): connects directly to localhost:8080.
/// Running on Android Emulator: connects to 10.0.2.2:8080.
class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'http://localhost:8080/api';
      }
      if (Platform.isAndroid) {
        // When running on physical phone via USB debugging, 'adb reverse tcp:8080 tcp:8080'
        // forwards 127.0.0.1:8080 over the USB cable to your laptop's backend.
        return 'http://127.0.0.1:8080/api';
      }
    } catch (_) {
      return 'http://localhost:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String oauth = '/auth/oauth';
}

