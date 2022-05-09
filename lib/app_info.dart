import 'package:flutter/services.dart';

class AppInfo {
  static const MethodChannel _channel = MethodChannel('appInfo');

  static Future<String?> get appVersion async {
    final String? version = await _channel.invokeMethod('getAppVersion');
    return version;
  }
}
