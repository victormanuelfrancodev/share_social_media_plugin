
[![N|Social media](https://i.ibb.co/QYMBDZ5/share.png)](https://ibb.co/kqXnmpd)

# share_social_media_plugin_example

Demonstrates how to use the share_social_media_plugin plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Share text in your social media.

  - Line  (iOS/Android)
  - Twitter (ios/Android)
  - Instagram (coming)

### Example

Share in Line.

```dart
 await ShareSocialMediaPlugin.shareLine("My share text");
```

Share in Twitter
```dart
//Set keys
final twitterLogin = new ShareSocialMediaPlugin(
      consumerKey: "consumerKey",
      consumerSecret: 'consumerSecret');

          onPressed: () async{
                      if (Platform.isAndroid) {
                        twitterLogin.shareTwitter("ありがとう");
                      } else if (Platform.isIOS) {
                        var sessionTwitter = await twitterLogin.currentSessionIOS();
                        var tweet = await twitterLogin.shareTwitteriOS(sessionTwitter["outhToken"], sessionTwitter["oauthTokenSecret"],
                            "ありがとう", twitterLogin.consumerKey, twitterLogin.consumerSecret);
                        print(tweet.body.toString());
                      }
                    },
```
**Note For iOS Twitter
In plist
add:
```
	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>TwitterLoginSampleOAuth</string>
			</array>
		</dict>
	</array>

```
!IMPORTANT

In your developer.twitter.com app , you need add the next callback
-TwitterLoginSampleOAuth://
-twittersdk://

Thank you for your repo
https://github.com/bodnarrr/flutter_twitter_login/blob/master/android/src/main/java/com/bodnarrr/fluttertwitterlogin/fluttertwitterlogin/TwitterLoginPlugin.java