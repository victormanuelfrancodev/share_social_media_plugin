import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_social_media_plugin/share_social_media_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('share_social_media_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ShareSocialMediaPlugin.platformVersion, '42');
  });
}
