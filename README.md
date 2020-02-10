# share_social_media_plugin

Share social media plugin 

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.


Share text in your social media.

  - Line (Android / iOS)
  - Twitter (Android / iOS)
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