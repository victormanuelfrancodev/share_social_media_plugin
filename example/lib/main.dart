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
      ShareSocialMediaPlugin(consumerKey: "3WGlyun7pWXYP6s5GjFiaCFCI", consumerSecret: 'pyNN593fU4hHOvSEcatcXAo1epk5pv1f2T6rAYMuXqyZgMH0OT');
  var titleTwitterButton = "Connect Twitter";
  var outhTokenTwitter;
  var oauthTokenSecretTwitter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    twitterLogin.isSessionActive.then((value) {
      print(value);
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
             child: Text('Get image profile Twitter only android'),
              onPressed: () async{
                print(await twitterLogin.getProfileImage());
              },
            ),
            RaisedButton(
              child: Text('Share in Twitter', style: TextStyle(fontSize: 20)),
              onPressed: () async {
                if (Platform.isAndroid) {
                  twitterLogin.isSessionActive.then((isConnected) async{
                    if (!isConnected){
                      twitterLogin.connectTwitter();
                    }
                    else{
                      var response =
                      await twitterLogin.shareTwitter("example test in android");
                      if (response['text'] != null) {
                        //Success

                      } else {
                        //Fail
                      }
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
