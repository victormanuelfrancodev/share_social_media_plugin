import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:share_social_media_plugin/share_social_media_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final twitterLogin = new ShareSocialMediaPlugin(
      consumerKey: "YOUR_CONSUMER_KEY",
      consumerSecret: 'YOUR CONSUMER SECRECT');

  Future<int> _startSession() async {
    var sessionData = await twitterLogin.currentSession;

    if (sessionData == null) {
      var result = await twitterLogin.authorize();
    } else
      print(sessionData);

    return 0;
  }

  void _logout() async {
    await twitterLogin.logOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Share social media'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                await ShareSocialMediaPlugin.shareLine("http://www.google.com");
              },
              child: Text('Share in Line', style: TextStyle(fontSize: 20)),
            ),
            new RaisedButton(
              child:
                  new Text('Share in Twitter', style: TextStyle(fontSize: 20)),
              onPressed: () async {
                if (Platform.isAndroid) {
                  twitterLogin.shareTwitter("ありがとう");
                } else if (Platform.isIOS) {
                  var sessionTwitter = await twitterLogin.currentSessionIOS();
                  var tweet = await twitterLogin.shareTwitteriOS(
                      sessionTwitter["outhToken"],
                      sessionTwitter["oauthTokenSecret"],
                      "ありがとう",
                      twitterLogin.consumerKey,
                      twitterLogin.consumerSecret);
                  print(tweet.body.toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
