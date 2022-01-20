import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:share_social_media_plugin/twitter_client.dart';

import 'TweetModel/user.dart';

class ShareSocialMediaPlugin {
  ShareSocialMediaPlugin({
    required this.consumerKey,
    required this.consumerSecret,
  })  : assert(consumerKey != null && consumerKey.isNotEmpty, 'Consumer key may not be null or empty.'),
        assert(consumerSecret != null && consumerSecret.isNotEmpty, 'Consumer secret may not be null or empty.'),
        _keys = {
          'consumerKey': consumerKey,
          'consumerSecret': consumerSecret,
        };

  final String consumerKey;
  final String consumerSecret;
  final Map<String, String?> _keys;

  static const MethodChannel channel = const MethodChannel('share_social_media_plugin');

  //Share Line
  static Future<bool?> shareLine(String urlTemp) async {
    return await channel.invokeMethod('shareLine', <String, dynamic>{'urlTemp': urlTemp});
  }

  static Future<void> shareInstagram(String text, String assetFile, String assetNameBackground) async {
    return channel.invokeMethod('shareInstagram', <String, dynamic>{'text': text, 'assetFile': assetFile, 'assetNameBackground': assetNameBackground});
  }

  static Future<void> shareInstagramAlbum() async {
    return channel.invokeMethod('shareInstagramAlbum');
  }

  //Share Twitter
  Future<String> getProfileImage() async {
    TwitterClient.setKeys(this.consumerKey, this.consumerSecret);
    var tc = TwitterClient();
    User user = await (tc.getProfile() as FutureOr<User>);
    return user.profileUrl;
  }

  connectTwitter() {
    TwitterClient.setKeys(this.consumerKey, this.consumerSecret);
    TwitterClient();
  }

  Future<bool> connectedInTwitter() async {
    return (TwitterClient.twitter != null);
  }

  Future<Map?> shareTwitter(String urlTemp) async {
    TwitterClient.setKeys(this.consumerKey, this.consumerSecret);
    var tc = TwitterClient();
    return tc.tweetPromo(urlTemp);
  }

  Future<http.Response> shareTwitteriOS(String tk, String tsk, String status, String ck, String csk) async {
    String base = '/1.1/statuses/update.json';
    var params = [
      ["status", status]
    ];

    String oauthConsumer = 'oauth_consumer_key="${Uri.encodeComponent(ck)}"';
    String oauthToken = 'oauth_token="${Uri.encodeComponent(tk)}"';
    String oauthNonce = 'oauth_nonce="${Uri.encodeComponent(randomAlphaNumeric(42))}"';
    String oauthVersion = 'oauth_version="${Uri.encodeComponent("1.0")}"';
    String oauthTime = 'oauth_timestamp="${(DateTime.now().millisecondsSinceEpoch / 1000).toString()}"';
    String oauthMethod = 'oauth_signature_method="${Uri.encodeComponent("HMAC-SHA1")}"';
    var oauthList = [oauthConsumer.replaceAll('"', ""), oauthNonce.replaceAll('"', ""), oauthMethod.replaceAll('"', ""), oauthTime.replaceAll('"', ""), oauthToken.replaceAll('"', ""), oauthVersion.replaceAll('"', "")];
    var paramMap = Map<String, String>();

    for (List<String> param in params) {
      oauthList.add('${Uri.encodeComponent(param[0])}=${Uri.encodeComponent(param[1])}');
      paramMap[param[0]] = param[1];
    }

    oauthList.sort();
    String oauthSig = 'oauth_signature="${Uri.encodeComponent(generateSignature("POST", "https://api.twitter.com$base", oauthList, tsk, csk))}"';
    print(oauthSig);
    return await http.post(new Uri.https("api.twitter.com", base, paramMap), headers: {"Authorization": 'Oauth $oauthConsumer, $oauthNonce, $oauthSig, $oauthMethod, $oauthTime, $oauthToken, $oauthVersion', "Content-Type": "application/json"}).timeout(Duration(seconds: 15));
  }

  static String generateSignature(String method, String base, List<String> sortedItems, String tsk, String csk) {
    String param = '';

    for (int i = 0; i < sortedItems.length; i++) {
      if (i == 0)
        param = sortedItems[i];
      else
        param += '&${sortedItems[i]}';
    }

    String sig = '$method&${Uri.encodeComponent(base)}&${Uri.encodeComponent(param)}';
    String key = '${Uri.encodeComponent(csk)}&${Uri.encodeComponent(tsk)}';
    var digest = Hmac(sha1, utf8.encode(key)).convert(utf8.encode(sig));
    return base64.encode(digest.bytes);
  }

  //Login Twitter
  Future<Map<dynamic, dynamic>?> currentSessionIOS() async {
    return channel.invokeMethod('getCurrentSessionIOS', _keys);
  }

  Future<bool> get isSessionActive async => await currentSession != null;

  Future<TwitterSession?> get currentSession async {
    final Map<dynamic, dynamic>? session = await channel.invokeMethod('getCurrentSession', _keys);

    if (session == null) {
      return null;
    }

    return new TwitterSession.fromMap(session.cast<String, dynamic>());
  }

  Future<TwitterLoginResult> authorize() async {
    final Map<dynamic, dynamic> result = await (channel.invokeMethod('authorize', _keys) as FutureOr<Map<dynamic, dynamic>>);

    return new TwitterLoginResult._(result.cast<String, dynamic>());
  }

  /// Logs the currently logged in user out.
  Future<void> logOut() async => channel.invokeMethod('logOut', _keys);
}

//Twitter Session
class TwitterSession {
  final String? secret;
  final String? token;

  final String? userId;

  final String? username;

  TwitterSession.fromMap(Map<String, dynamic> map)
      : secret = map['secret'],
        token = map['token'],
        userId = map['userId'],
        username = map['username'];
  Map<String, dynamic> toMap() {
    return {
      'secret': secret,
      'token': token,
      'userId': userId,
      'username': username,
    };
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is TwitterSession && runtimeType == other.runtimeType && secret == other.secret && token == other.token && userId == other.userId && username == other.username;

  @override
  int get hashCode => secret.hashCode ^ token.hashCode ^ userId.hashCode ^ username.hashCode;
}

enum TwitterLoginStatus {
  loggedIn,
  cancelledByUser,
  error,
}

class TwitterLoginResult {
  final TwitterLoginStatus status;
  final TwitterSession? session;
  final String? errorMessage;

  TwitterLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status'], map['errorMessage']),
        session = map['session'] != null
            ? new TwitterSession.fromMap(
                map['session'].cast<String, dynamic>(),
              )
            : null,
        errorMessage = map['errorMessage'];

  static TwitterLoginStatus _parseStatus(String? status, String? errorMessage) {
    switch (status) {
      case 'loggedIn':
        return TwitterLoginStatus.loggedIn;
      case 'error':
        if (errorMessage!.contains('canceled') || errorMessage.contains('cancelled')) {
          return TwitterLoginStatus.cancelledByUser;
        }

        return TwitterLoginStatus.error;
    }

    throw new StateError('Invalid status: $status');
  }
}
