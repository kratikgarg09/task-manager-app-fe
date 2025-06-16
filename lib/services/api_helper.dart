import 'dart:io';
import 'package:flutter/foundation.dart';
import "package:universal_io/io.dart" as universal;

class ApiHelper {
  static String getBaseUrl() {
    if (universal.Platform.isAndroid) {
      // On Android Emulator, use 10.0.2.2 to access host machine
      return 'http://192.168.74.240:8080/api';
    } else if (universal.Platform.isIOS) {
      // On iOS simulator, localhost works
      return 'http://localhost:8080/api';
    } else if (universal.Platform.isWindows ||
        universal.Platform.isMacOS ||
        universal.Platform.isLinux) {
      // Desktop testing
      return 'http://localhost:8080/api';
    } else if (kIsWeb) {
      // For Flutter web
      return 'http://localhost:8080/api';
    } else {
      // On real devices, use your local network IP
      return 'http://192.168.74.240:8080/api'; // <-- Replace with your IP
    }
  }
}
