import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'dart:io' show Platform;
import 'package:share_social_media_plugin/share_social_media_plugin.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final twitterLogin = ShareSocialMediaPlugin(
      consumerKey: "3WGlyun7pWXYP6s5GjFiaCFCI",
      consumerSecret: 'pyNN593fU4hHOvSEcatcXAo1epk5pv1f2T6rAYMuXqyZgMH0OT');
  var titleTwitterButton = "Connect Twitter";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    twitterLogin.isSessionActive.then((value) {
      if (value) {
        titleTwitterButton = "Share in twitter";
      } else {
        titleTwitterButton = "Connect to Twitter";
      }
      setState(() {});
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
                try {
                  var result = await ShareSocialMediaPlugin.shareLine(
                      "http://www.google.com");
                  print(result);
                } on PlatformException catch (e) {
                  print("sucedio un error");
                }
              },
              child: Text('Share in Line', style: TextStyle(fontSize: 20)),
            ),
            RaisedButton(
              child: Text(titleTwitterButton, style: TextStyle(fontSize: 20)),
              onPressed: () async {
                if (Platform.isAndroid) {
                  var result =
                      await twitterLogin.shareTwitter("conectado desde plugin");
                  print(result);
                  if (result != null) {
                    if (result == "success") {
                      print("success!");
                    } else {
                      print("fail");
                    }
                  }
                } else if (Platform.isIOS) {
                  var sessionTwitter = await twitterLogin.currentSessionIOS();
                  var tweet = await twitterLogin.shareTwitteriOS(
                      sessionTwitter["outhToken"],
                      sessionTwitter["oauthTokenSecret"],
                      "test cpmplete future",
                      twitterLogin.consumerKey,
                      twitterLogin.consumerSecret);

                  final response = json.decode(tweet.body);
                  if (response['text'] != null) {
                    print("success");
                  } else {
                    print("fail");
                  }
                }
              },
            ),
            RaisedButton(
              onPressed: () async {
                await ShareSocialMediaPlugin.shareInstagram(
                    "hello", "assets/nofumar.jpg", "assets/logo2323.png");
              },
              child: Text('Share in Instagram', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
