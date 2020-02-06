package social.share.com.share_social_media_plugin;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
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

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.HashMap;

/** Handles share intent. */
class ShareLine extends Callback<TwitterSession> implements PluginRegistry.ActivityResultListener{

  private Activity activity;
  private TwitterAuthClient authClientInstance;
  private Result pendingResult;


  ShareLine(Activity activity) {
    this.activity = activity;

  }

  /**
   * Sets the activity when an activity is available. When the activity becomes unavailable, use
   * this method to set it to null.
   */
  void setActivity(Activity activity) {
    this.activity = activity;

  }

  void share(String text) {
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

  void setPendingResult(String methodName, MethodChannel.Result result) {
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

  void getCurrentSession(Result result, MethodCall call) {
    initializeAuthClient(call);
    TwitterSession session = TwitterCore.getInstance().getSessionManager().getActiveSession();
    HashMap<String, Object> sessionMap = sessionToMap(session);
    //Log.d("client",session.getUserName());
    result.success(sessionMap);
  }

  void authorize(Result result, MethodCall call) {
    setPendingResult("authorize", result);
   // Log.d("client","authorize");
    initializeAuthClient(call).authorize(activity,this);

  }

  private TwitterAuthClient initializeAuthClient(MethodCall call) {
    if (authClientInstance == null) {
      String consumerKey = call.argument("consumerKey");
      String consumerSecret = call.argument("consumerSecret");
      Log.d("Client","Iniciando sin internet");
      authClientInstance = configureClient(consumerKey, consumerSecret);
      Log.d("Client",authClientInstance.toString());
    }

    return authClientInstance;
  }

  private TwitterAuthClient configureClient(String consumerKey, String consumerSecret) {
    TwitterAuthConfig authConfig = new TwitterAuthConfig(consumerKey, consumerSecret);
    TwitterConfig config = new TwitterConfig.Builder(activity.getApplicationContext())
            .twitterAuthConfig(authConfig)
            .build();
    Twitter.initialize(config);
    Log.d("Client",config.toString());
    return new TwitterAuthClient();
  }

   void logOut(Result result, MethodCall call) {
    CookieSyncManager.createInstance(activity.getApplicationContext());
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
    Log.d("client","successss");
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
    Log.d("client",exception.getMessage());
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
    Log.d("client","funcionando");
    if (authClientInstance != null) {
      authClientInstance.onActivityResult(requestCode, resultCode, data);
    }

    return false;
  }

}