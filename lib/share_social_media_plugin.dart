import 'dart:async';

import 'package:flutter/services.dart';

class ShareSocialMediaPlugin {
  static const MethodChannel _channel =
      const MethodChannel('share_social_media_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> shareLine(String urlTemp) async {
    return _channel
        .invokeMethod('shareLine', <String, dynamic>{'urlTemp': urlTemp});
  }
}
