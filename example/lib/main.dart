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
      consumerKey: "3WGlyun7pWXYP6s5GjFiaCFCI",
      consumerSecret: 'pyNN593fU4hHOvSEcatcXAo1epk5pv1f2T6rAYMuXqyZgMH0OT');
  var titleTwitterButton = "Connect Twitter";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    twitterLogin.isSessionActive.then((value){
      if (value){
        titleTwitterButton = "Share in twitter";
      }else{
        titleTwitterButton = "Connect to Twitter";
      }
      setState(() {

      });
    });

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
              child: Text(titleTwitterButton, style: TextStyle(fontSize: 20)),
              onPressed: () async {
                if (Platform.isAndroid) {
                       twitterLogin.shareTwitter("conectado desde plugin");
                     }
                  else if (Platform.isIOS) {
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
