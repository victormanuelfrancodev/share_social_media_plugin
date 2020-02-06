package social.share.com.share_social_media_plugin;

import android.content.Intent;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;

import com.twitter.sdk.android.core.Callback;
import com.twitter.sdk.android.core.Twitter;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.core.TwitterException;
import com.twitter.sdk.android.core.TwitterSession;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import android.app.Activity;
import android.net.Uri;
import android.util.Log;

/** Plugin method host for presenting a share sheet via Intent */
public class ShareSocialMediaPlugin extends Callback<TwitterSession> implements MethodCallHandler, PluginRegistry.ActivityResultListener {

  private static final String CHANNEL_NAME = "share_social_media_plugin";
  private static final String METHOD_GET_CURRENT_SESSION = "getCurrentSession";
  private static final String METHOD_AUTHORIZE = "authorize";
  private static final String METHOD_LOG_OUT = "logOut";
  private static final String METHOD_LINE_SHARE = "shareLine";

  private final Registrar registrar;

  private TwitterAuthClient authClientInstance;
  private Result pendingResult;
  Activity activity;
  MethodChannel methodChannel;

  public static void registerWith(Registrar registrar) {

    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    final ShareSocialMediaPlugin plugin = new ShareSocialMediaPlugin(registrar,registrar.activity(),channel);
    channel.setMethodCallHandler(plugin);
  }

  private ShareSocialMediaPlugin(Registrar registrar,Activity activity, MethodChannel methodChannel) {
    this.registrar = registrar;
    this.activity = activity;
    this.methodChannel = methodChannel;
    this.methodChannel.setMethodCallHandler(this);
    registrar.addActivityResultListener(this);
  }


  void shareLine(String text) {
    if (text == null || text.isEmpty()) {
      throw new IllegalArgumentException("Non-empty text expected");
    }
    Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://social-plugins.line.me/lineit/share?url="+text));
    Intent chooserIntent = Intent.createChooser(browserIntent, null /* dialog title optional */);
    if (activity != null) {
      activity.startActivity(browserIntent);
    }else {
      chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      activity.startActivity(chooserIntent);
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case METHOD_GET_CURRENT_SESSION:
        getCurrentSession(result, call);
        break;
      case METHOD_AUTHORIZE:
        authorize(result, call);
        break;
      case METHOD_LOG_OUT:
        logOut(result, call);
        break;
      case METHOD_LINE_SHARE:
          shareLine((String) call.argument("urlTemp"));
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void setPendingResult(String methodName, MethodChannel.Result result) {
    if (pendingResult != null) {
      result.error(
              "TWITTER_LOGIN_IN_PROGRESS",
              methodName + " called while another Twitter " +
                      "login operation was in progress.",
              null
      );
    }

    pendingResult = result;
  }

  private void getCurrentSession(Result result, MethodCall call) {
    initializeAuthClient(call);
    TwitterSession session = TwitterCore.getInstance().getSessionManager().getActiveSession();
    HashMap<String, Object> sessionMap = sessionToMap(session);

    result.success(sessionMap);
  }

  private void authorize(Result result, MethodCall call) {
    setPendingResult("authorize", result);
    initializeAuthClient(call).authorize(registrar.activity(), this);
  }

  private TwitterAuthClient initializeAuthClient(MethodCall call) {
    if (authClientInstance == null) {
      String consumerKey = call.argument("consumerKey");
      String consumerSecret = call.argument("consumerSecret");

      authClientInstance = configureClient(consumerKey, consumerSecret);
    }

    return authClientInstance;
  }

  private TwitterAuthClient configureClient(String consumerKey, String consumerSecret) {
    TwitterAuthConfig authConfig = new TwitterAuthConfig(consumerKey, consumerSecret);
    TwitterConfig config = new TwitterConfig.Builder(registrar.context())
            .twitterAuthConfig(authConfig)
            .build();
    Twitter.initialize(config);

    return new TwitterAuthClient();
  }

  private void logOut(Result result, MethodCall call) {
    CookieSyncManager.createInstance(registrar.context());
    CookieManager cookieManager = CookieManager.getInstance();
    cookieManager.removeSessionCookie();

    initializeAuthClient(call);
    TwitterCore.getInstance().getSessionManager().clearActiveSession();
    result.success(null);
  }

  private HashMap<String, Object> sessionToMap(final TwitterSession session) {
    if (session == null) {
      return null;
    }

    return new HashMap<String, Object>() {{
      put("secret", session.getAuthToken().secret);
      put("token", session.getAuthToken().token);
      put("userId", String.valueOf(session.getUserId()));
      put("username", session.getUserName());
    }};
  }

  @Override
  public void success(final com.twitter.sdk.android.core.Result<TwitterSession> result) {
    if (pendingResult != null) {
      final HashMap<String, Object> sessionMap = sessionToMap(result.data);
      final HashMap<String, Object> resultMap = new HashMap<String, Object>() {{
        put("status", "loggedIn");
        put("session", sessionMap);
      }};

      pendingResult.success(resultMap);
      pendingResult = null;
    }
  }

  @Override
  public void failure(final TwitterException exception) {
    if (pendingResult != null) {
      final HashMap<String, Object> resultMap = new HashMap<String, Object>() {{
        put("status", "error");
        put("errorMessage", exception.getMessage());
      }};

      pendingResult.success(resultMap);
      pendingResult = null;
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (authClientInstance != null) {
      authClientInstance.onActivityResult(requestCode, resultCode, data);
    }

    return false;
  }
}