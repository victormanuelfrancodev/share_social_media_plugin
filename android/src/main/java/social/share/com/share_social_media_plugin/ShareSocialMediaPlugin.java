package social.share.com.share_social_media_plugin;

import android.app.Dialog;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.os.Environment;
import android.provider.ContactsContract;
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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
import android.widget.Toast;

/** Plugin method host for presenting a share sheet via Intent */
public class ShareSocialMediaPlugin extends Callback<TwitterSession> implements MethodCallHandler, PluginRegistry.ActivityResultListener {

  private static final String CHANNEL_NAME = "share_social_media_plugin";
  private static final String METHOD_GET_CURRENT_SESSION = "getCurrentSession";
  private static final String METHOD_AUTHORIZE = "authorize";
  private static final String METHOD_LOG_OUT = "logOut";
  private static final String METHOD_LINE_SHARE = "shareLine";
  private static final String METHOD_INSTAGRAM_SHARE = "shareInstagram";
  private static final String METHOD_INSTAGRA_SHARE_ALBUM = "shareInstagramAlbum";

  private final Registrar registrar;
  private TwitterAuthClient authClientInstance;
  private Result pendingResult;
  Activity activity;
  MethodChannel methodChannel;
  AssetManager assetManager;
  private static Context context;

  public static void registerWith(Registrar registrar) {

    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    final ShareSocialMediaPlugin plugin = new ShareSocialMediaPlugin(registrar,registrar.activity(),channel);
    context = registrar.activity().getApplication();
    channel.setMethodCallHandler(plugin);
  }

  private ShareSocialMediaPlugin(Registrar registrar,Activity activity, MethodChannel methodChannel) {
    this.registrar = registrar;
    this.activity = activity;
    this.methodChannel = methodChannel;
    this.assetManager = registrar.context().getAssets();
    this.methodChannel.setMethodCallHandler(this);
    registrar.addActivityResultListener(this);
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
          shareLine((String) call.argument("urlTemp"),result);
        break;
      case METHOD_INSTAGRAM_SHARE:
        insertInstagram(result,call,(String) call.argument("text"),(String) call.argument("assetFile"),(String) call.argument("assetNameBackground"));
        break;
      case METHOD_INSTAGRA_SHARE_ALBUM:
        insertInstagramAlbums(result,call);
      default:
        result.notImplemented();
        break;
    }
  }

//Line
  void shareLine(String text,Result result) {
    if (text == null || text.isEmpty()) {
      throw new IllegalArgumentException("Non-empty text expected");
    }
    Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://social-plugins.line.me/lineit/share?url="+text));
    Intent chooserIntent = Intent.createChooser(browserIntent, null /* dialog title optional */);
    if (activity != null) {
      activity.startActivity(browserIntent);
      result.error("0","Dont have line install","You need install line");
    }else {
      try
      {
        chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(chooserIntent);
        result.success(true);
      }catch (Exception e){
        result.error("1","Error to open Line","Some error happened");
      }
    }
  }

  //Twitter
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
    Log.d("request",Integer.toString(requestCode));
    if (requestCode == 0){
      Uri uri = data.getData();
      shareInstagramAlbum(uri);
    }
    return false;
  }

  ///INSTAGRAM

  private void insertInstagram(Result result, MethodCall call,String text,String assetFile,String backgroundFile){

    if (!appInstalledOrNot()) {
      Dialog dialog=new Dialog(activity);
      dialog.setTitle("Instagram Application is not installed");
      dialog.show();
      return;
    }
    shareInstagram(text,assetFile); // share image from gallery
  }

  private void insertInstagramAlbums(Result result, MethodCall call){

    if (!appInstalledOrNot()) {
      Dialog dialog=new Dialog(activity);
      dialog.setTitle("Instagram Application is not installed");
      dialog.show();
      return;
    }
    shareFromGallery(); // share image from gallery
  }

  //Instagram functions

  private boolean appInstalledOrNot() {

    boolean app_installed = false;
    try {
      ApplicationInfo info = activity.getPackageManager().getApplicationInfo("com.instagram.android", 0);
      app_installed = true;
    } catch (PackageManager.NameNotFoundException e) {
      app_installed = false;
    }
    return app_installed;
  }

  /*This method invoke gallery or any application which support image/* mime type */
  private void shareFromGallery(){
      try{
          Intent intent = new Intent();
          intent.setType("image/*");
          intent.setAction(Intent.ACTION_GET_CONTENT);
          activity.startActivityForResult(Intent.createChooser(intent, "Select Picture"), 0);
      }catch (Exception e){
          Log.d("error",e.getMessage());
      }
  }

  private void shareInstagramAlbum(Uri uri){

      Intent shareIntent = new Intent(android.content.Intent.ACTION_SEND);
      shareIntent.setType("image/*");

      shareIntent.putExtra(Intent.EXTRA_STREAM, uri);
      shareIntent.setPackage("com.instagram.android");
      Intent chooserIntent = Intent.createChooser(shareIntent, null);
      try {
        if (activity != null) {
          activity.startActivity(shareIntent);
        } else {
          chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
          activity.startActivity(chooserIntent);
        }
      } catch (Exception e) {
        Log.d("error", e.getMessage());
      }
  }

  private void shareInstagramSticker(String text,String assetFile){

  }

  private void shareInstagram(String text,String assetFile){

    Log.d("assetFile",assetFile);
    String key = registrar.lookupKeyForAsset(assetFile);
    try {
      AssetFileDescriptor fd = assetManager.openFd(key);
      InputStream is = fd.createInputStream();
      Bitmap bitmap1 = BitmapFactory.decodeStream(is);
      Intent shareIntent = new Intent(android.content.Intent.ACTION_SEND);
      shareIntent.setType("image/*");
      shareIntent.putExtra(Intent.EXTRA_TEXT, "holaaaaa");
      shareIntent.putExtra(Intent.EXTRA_STREAM, getLocalBitmapUri(text,bitmap1,context));


      shareIntent.setPackage("com.instagram.android");
      Intent chooserIntent = Intent.createChooser(shareIntent, "share someee");
      try {
        if (activity != null) {
          activity.startActivity(shareIntent);
        } else {
          chooserIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
          activity.startActivity(chooserIntent);
        }
      } catch (Exception e) {
        Log.d("error", e.getMessage());
      }
    } catch (IOException e) {
      e.printStackTrace();
      Log.d("keyImage",e.getMessage());
    }
  }



  static public Uri getLocalBitmapUri(String text,Bitmap bmp, Context context) {
    Uri bmpUri = null;
    try {
      File file =  new File(context.getExternalFilesDir(Environment.DIRECTORY_PICTURES), "share_image_" + System.currentTimeMillis() + ".png");
      FileOutputStream out = new FileOutputStream(file);
      android.graphics.Bitmap.Config bitmapConfig = bmp.getConfig();
      if(bitmapConfig == null) {
        bitmapConfig = android.graphics.Bitmap.Config.ARGB_8888;
      }
      try {
        bmp = bmp.copy(bitmapConfig, true);
        Canvas canvas = new Canvas(bmp);
        Paint paint = new Paint();
        paint.setColor(Color.BLACK); // Text Color
        paint.setTextSize(32); // Text Size
        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_OVER));
        canvas.drawBitmap(bmp, 0, 0, paint);

        Rect bounds = new Rect();
        paint.getTextBounds(text, 0, text.length(), bounds);
        int x = (bmp.getWidth() - bounds.width())/6;
        int y = (bmp.getHeight() + bounds.height())/5;
        canvas.drawText(text, x, y, paint);
        bmp.compress(Bitmap.CompressFormat.PNG, 90, out);
        out.flush();
        out.close();
        bmpUri = Uri.fromFile(file);
      }catch (Exception e){
        e.printStackTrace();
      }
    }catch (FileNotFoundException e) {
      e.printStackTrace();
    }
    return bmpUri;
  }
}

