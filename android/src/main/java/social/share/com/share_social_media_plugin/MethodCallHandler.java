package social.share.com.share_social_media_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

/** Handles the method calls for the plugin. */
class MethodCallHandler implements MethodChannel.MethodCallHandler {

  private ShareLine share;

  MethodCallHandler(ShareLine share) {
    this.share = share;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("shareLine")) {
      if (!(call.arguments instanceof Map)) {
        throw new IllegalArgumentException("Map argument expected");
      }
      // Android does not support showing the share sheet at a particular point on screen.
      share.share((String) call.argument("urlTemp"));
      result.success(null);
    } else {
      result.notImplemented();
    }
  }
}