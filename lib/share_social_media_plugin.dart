import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ShareSocialMediaPlugin {

  ShareSocialMediaPlugin({
    @required this.consumerKey,
    @required this.consumerSecret,
  }) : assert(consumerKey != null && consumerKey.isNotEmpty,
  'Consumer key may not be null or empty.'),
        assert(consumerSecret != null && consumerSecret.isNotEmpty,
        'Consumer secret may not be null or empty.'),
        _keys = {
          'consumerKey': consumerKey,
          'consumerSecret': consumerSecret,
        };

  final String consumerKey;
  final String consumerSecret;
  final Map<String, String> _keys;

  static const MethodChannel _channel =
      const MethodChannel('share_social_media_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> shareLine(String urlTemp) async {
    return _channel
        .invokeMethod('shareLine', <String, dynamic>{'urlTemp': urlTemp});
  }


  //Login twitter

  Future<bool> get isSessionActive async => await currentSession != null;

  Future<TwitterSession> get currentSession async {
    final Map<dynamic, dynamic> session = await _channel.invokeMethod('getCurrentSession', _keys);

    if (session == null) {
      return null;
    }

    return new TwitterSession.fromMap(session.cast<String, dynamic>());
  }

  Future<TwitterLoginResult> authorize() async {
    final Map<dynamic, dynamic> result =
    await _channel.invokeMethod('authorize', _keys);

    return new TwitterLoginResult._(result.cast<String, dynamic>());
  }

  /// Logs the currently logged in user out.
  Future<void> logOut() async => _channel.invokeMethod('logOutTwitter', _keys);
}

//Twitter Session
class TwitterSession {
  final String secret;
  final String token;

  final String userId;

  final String username;

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
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TwitterSession &&
              runtimeType == other.runtimeType &&
              secret == other.secret &&
              token == other.token &&
              userId == other.userId &&
              username == other.username;

  @override
  int get hashCode =>
      secret.hashCode ^ token.hashCode ^ userId.hashCode ^ username.hashCode;
}

enum TwitterLoginStatus {
  loggedIn,
  cancelledByUser,
  error,
}

class TwitterLoginResult {

  final TwitterLoginStatus status;
  final TwitterSession session;
  final String errorMessage;

  TwitterLoginResult._(Map<String, dynamic> map)
      : status = _parseStatus(map['status'], map['errorMessage']),
        session = map['session'] != null
            ? new TwitterSession.fromMap(
          map['session'].cast<String, dynamic>(),
        )
            : null,
        errorMessage = map['errorMessage'];

  static TwitterLoginStatus _parseStatus(String status, String errorMessage) {
    switch (status) {
      case 'loggedIn':
        return TwitterLoginStatus.loggedIn;
      case 'error':
        if (errorMessage.contains('canceled') ||
            errorMessage.contains('cancelled')) {
          return TwitterLoginStatus.cancelledByUser;
        }

        return TwitterLoginStatus.error;
    }

    throw new StateError('Invalid status: $status');
  }
}