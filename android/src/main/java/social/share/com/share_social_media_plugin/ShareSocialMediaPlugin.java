package social.share.com.share_social_media_plugin;

import android.app.Activity;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/** Plugin method host for presenting a share sheet via Intent */
public class ShareSocialMediaPlugin implements FlutterPlugin, ActivityAware  {

  private static final String CHANNEL = "share_social_media_plugin";
  private MethodCallHandler handler;
  private ShareLine share;
  private MethodChannel methodChannel;
  private final Registrar registrar;


  public static void registerWith(Registrar registrar) {
    ShareSocialMediaPlugin plugin = new ShareSocialMediaPlugin(registrar);
    plugin.setUpChannel(registrar.activity(), registrar.messenger(), registrar);
    Log.d("client","registerwith ");
  }

  private ShareSocialMediaPlugin(Registrar registrar){
    this.registrar = registrar;
    registrar.addActivityResultListener(this);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    setUpChannel(null, binding.getFlutterEngine().getDartExecutor(),null);
    Log.d("client","onAttachedToEngine");
  }


  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    share = null;
    Log.d("client","onDetachedFromEngine");
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    share.setActivity(binding.getActivity());
    Log.d("client","onAttachedToActivity");
  }

  @Override
  public void onDetachedFromActivity() {

    tearDownChannel();
    Log.d("client","onDetachedFromActivity");
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
    Log.d("client","onReattachedToActivityForConfigChanges");
  }

  @Override
  public void onDetachedFromActivityForConfigChanges()
  {
    Log.d("client","onDetachedFromActivityForConfigChanges");
    onDetachedFromActivity();
  }

  private void setUpChannel(Activity activity, BinaryMessenger messenger, Registrar registrar) {
    Log.d("client","setUpChannel");
    if(activity == null){
      Log.d("client","activity es null");
    }else{
      Log.d("client","activity no es null");
    }

    methodChannel = new MethodChannel(messenger, CHANNEL);
    share = new ShareLine(activity);
    handler = new MethodCallHandler(share);
    methodChannel.setMethodCallHandler(handler);
  }

  private void tearDownChannel() {
    Log.d("client","tearDownChannel");
    share.setActivity(null);
    methodChannel.setMethodCallHandler(null);
  }
}