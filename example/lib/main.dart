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
  final twitterLogin =
      ShareSocialMediaPlugin(consumerKey: "", consumerSecret: '');
  var titleTwitterButton = "Connect Twitter";
  var outhTokenTwitter;
  var oauthTokenSecretTwitter;

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
              child: Text('Share in Twitter', style: TextStyle(fontSize: 20)),
              onPressed: () async {
                if (Platform.isAndroid) {
                  twitterLogin.connectedInTwitter().then((value) async {
                    if (value) {
                      var response =
                          await twitterLogin.shareTwitter("code tesr");
                      if (response['text'] != null) {
                        //Success
                        print(response);
                      } else {
                        //Fail
                        print(response);
                      }
                    } else {
                      //Connect your account
                      twitterLogin.connectTwitter();
                    }
                  });
                } else if (Platform.isIOS) {
                  if (outhTokenTwitter != null) {
                    var tweet = await twitterLogin.shareTwitteriOS(
                        outhTokenTwitter,
                        oauthTokenSecretTwitter,
                        "test6",
                        twitterLogin.consumerKey,
                        twitterLogin.consumerSecret);

                    final response = json.decode(tweet.body);
                    if (response['text'] != null) {
                      //Success
                      print(tweet.body);
                    } else {
                      //Fail
                      print(tweet.body);
                    }
                  } else {
                    //Connect twitter
                    var sessionTwitter = await twitterLogin.currentSessionIOS();
                    outhTokenTwitter = sessionTwitter["outhToken"];
                    oauthTokenSecretTwitter =
                        sessionTwitter["oauthTokenSecret"];
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
