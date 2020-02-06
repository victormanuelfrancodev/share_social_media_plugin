import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:share_social_media_plugin/share_social_media_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final twitterLogin =
  new ShareSocialMediaPlugin(consumerKey: "3WGlyun7pWXYP6s5GjFiaCFCI", consumerSecret: 'pyNN593fU4hHOvSEcatcXAo1epk5pv1f2T6rAYMuXqyZgMH0OT');

   Future<int> _startSession() async {
    var sessionData = await twitterLogin.currentSession;

    if (sessionData == null) {
      var result = await twitterLogin.authorize();
      print(result.session);
    } else
      print(sessionData);

    return 0;
  }

  void _logout() async {
    var twitterLogin =
    new ShareSocialMediaPlugin(consumerKey: "3WGlyun7pWXYP6s5GjFiaCFCI", consumerSecret: 'pyNN593fU4hHOvSEcatcXAo1epk5pv1f2T6rAYMuXqyZgMH0OT');
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
              child: Text('Line', style: TextStyle(fontSize: 20)),
            ),
            RaisedButton(
              onPressed: () { _startSession();},
              child: Text('Twitter', style: TextStyle(fontSize: 20)),
            ),
            new RaisedButton(
              child: new Text('Log out'),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
