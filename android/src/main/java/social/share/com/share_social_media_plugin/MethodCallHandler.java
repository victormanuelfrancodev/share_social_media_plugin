package social.share.com.share_social_media_plugin;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

/** Handles the method calls for the plugin. */
class MethodCallHandler implements MethodChannel.MethodCallHandler {

  private ShareLine shareLine;


  MethodCallHandler(ShareLine shareLine) {
    this.shareLine = shareLine;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    //shareTwitter
    if (call.method.equals("shareLine")) {
      if (!(call.arguments instanceof Map)) {
        throw new IllegalArgumentException("Map argument expected");
      }
      // Android does not support showing the share sheet at a particular point on screen.
      shareLine.share((String) call.argument("urlTemp"));
      result.success(null);
    } else if (call.method.equals("getCurrentSessionTwitter")) {
      shareLine.getCurrentSession(result, call);
    } else if (call.method.equals("authorizeTwitter")){
      shareLine.authorize(result, call);
    }else if (call.method.equals("logOutTwitter")){
      shareLine.logOut(result, call);
    }
    else {
      result.notImplemented();
    }
  }
}