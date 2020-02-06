package social.share.com.share_social_media_plugin;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

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
      shareLine.share((String) call.argument("urlTemp"));
      result.success(null);
    } else if (call.method.equals("getCurrentSession")) {
      shareLine.getCurrentSession(result, call);
    } else if (call.method.equals("authorize")){
      shareLine.authorize(result, call);
    }else if (call.method.equals("logOutTwitter")){
      shareLine.logOut(result, call);
    }
    else {
      result.notImplemented();
    }
  }
}