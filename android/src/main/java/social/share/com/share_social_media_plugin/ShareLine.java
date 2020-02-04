package social.share.com.share_social_media_plugin;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

/** Handles share intent. */
class ShareLine {

  private Activity activity;


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
/*
    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_TEXT, text);
    shareIntent.putExtra(Intent.EXTRA_SUBJECT, "example");
    shareIntent.setType("text/plain");
  */
    Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://social-plugins.line.me/lineit/share?url="+text));
    Intent chooserIntent = Intent.createChooser(browserIntent, null /* dialog title optional */);
    if (activity != null) {
      activity.startActivity(browserIntent);
    }else {
      chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      activity.startActivity(chooserIntent);
    }
  }
}