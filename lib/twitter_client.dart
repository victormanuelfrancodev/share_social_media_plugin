import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:share_social_media_plugin/share_social_media_plugin.dart';
import 'TweetModel/tweet.dart';
import 'TweetModel/user.dart';

class TwitterClient {
  static final TwitterClient _singleton = new TwitterClient._internal();
  static TwitterSession twitter;
  static User _profile;
  static String _consumerKey;
  static String _secretKey;

  factory TwitterClient() {
    _startSession();
    return _singleton;
  }

  TwitterClient._internal();

  static Future<int> _startSession() async {
    var twitterLogin = ShareSocialMediaPlugin(
        consumerKey: _consumerKey, consumerSecret: _secretKey);
    var sessionData = await twitterLogin.currentSession;

    if (sessionData == null) {
      var result = await twitterLogin.authorize();
      twitter = result.session;
    } else
      twitter = sessionData;

    return 0;
  }

  static void setKeys(String consumerKey, String secretKey) {
    _consumerKey = consumerKey;
    _secretKey = secretKey;
  }

  Future<User> getProfile() async {
    if (twitter == null) await _startSession();
    if (_profile != null) return _profile;

    _profile = await getUser(twitter.username);
    return _profile;
  }

  static String generateSignature(
      String method, String base, List<String> sortedItems) {
    String param = '';

    for (int i = 0; i < sortedItems.length; i++) {
      if (i == 0)
        param = sortedItems[i];
      else
        param += '&${sortedItems[i]}';
    }

    String sig =
        '$method&${Uri.encodeComponent(base)}&${Uri.encodeComponent(param)}';
    String key =
        '${Uri.encodeComponent(_secretKey)}&${Uri.encodeComponent(twitter.secret)}';
    var digest = Hmac(sha1, utf8.encode(key)).convert(utf8.encode(sig));
    return base64.encode(digest.bytes);
  }

  Future<http.Response> _twitterGet(
      String base, List<List<String>> params) async {
    if (twitter == null) await _startSession();

    String oauthConsumer =
        'oauth_consumer_key="${Uri.encodeComponent(_consumerKey)}"';
    String oauthToken = 'oauth_token="${Uri.encodeComponent(twitter.token)}"';
    String oauthNonce =
        'oauth_nonce="${Uri.encodeComponent(randomAlphaNumeric(42))}"';
    String oauthVersion = 'oauth_version="${Uri.encodeComponent("1.0")}"';
    String oauthTime =
        'oauth_timestamp="${(DateTime.now().millisecondsSinceEpoch / 1000).toString()}"';
    String oauthMethod =
        'oauth_signature_method="${Uri.encodeComponent("HMAC-SHA1")}"';
    var oauthList = [
      oauthConsumer.replaceAll('"', ""),
      oauthNonce.replaceAll('"', ""),
      oauthMethod.replaceAll('"', ""),
      oauthTime.replaceAll('"', ""),
      oauthToken.replaceAll('"', ""),
      oauthVersion.replaceAll('"', "")
    ];
    var paramMap = Map<String, String>();

    for (List<String> param in params) {
      oauthList.add(
          '${Uri.encodeComponent(param[0])}=${Uri.encodeComponent(param[1])}');
      paramMap[param[0]] = param[1];
    }

    oauthList.sort();
    String oauthSig =
        'oauth_signature="${Uri.encodeComponent(generateSignature("GET", "https://api.twitter.com$base", oauthList))}"';

    return await http
        .get(new Uri.https("api.twitter.com", base, paramMap), headers: {
      "Authorization":
          'Oauth $oauthConsumer, $oauthNonce, $oauthSig, $oauthMethod, $oauthTime, $oauthToken, $oauthVersion',
      "Content-Type": "application/json"
    }).timeout(Duration(seconds: 15));
  }

  Future<http.Response> _twitterPost(
      String base, List<List<String>> params) async {
    if (twitter == null) await _startSession();

    String oauthConsumer =
        'oauth_consumer_key="${Uri.encodeComponent(_consumerKey)}"';
    String oauthToken = 'oauth_token="${Uri.encodeComponent(twitter.token)}"';
    String oauthNonce =
        'oauth_nonce="${Uri.encodeComponent(randomAlphaNumeric(42))}"';
    String oauthVersion = 'oauth_version="${Uri.encodeComponent("1.0")}"';
    String oauthTime =
        'oauth_timestamp="${(DateTime.now().millisecondsSinceEpoch / 1000).toString()}"';
    String oauthMethod =
        'oauth_signature_method="${Uri.encodeComponent("HMAC-SHA1")}"';
    var oauthList = [
      oauthConsumer.replaceAll('"', ""),
      oauthNonce.replaceAll('"', ""),
      oauthMethod.replaceAll('"', ""),
      oauthTime.replaceAll('"', ""),
      oauthToken.replaceAll('"', ""),
      oauthVersion.replaceAll('"', "")
    ];
    var paramMap = Map<String, String>();

    for (List<String> param in params) {
      oauthList.add(
          '${Uri.encodeComponent(param[0])}=${Uri.encodeComponent(param[1])}');
      paramMap[param[0]] = param[1];
    }

    oauthList.sort();
    String oauthSig =
        'oauth_signature="${Uri.encodeComponent(generateSignature("POST", "https://api.twitter.com$base", oauthList))}"';

    return await http
        .post(new Uri.https("api.twitter.com", base, paramMap), headers: {
      "Authorization":
          'Oauth $oauthConsumer, $oauthNonce, $oauthSig, $oauthMethod, $oauthTime, $oauthToken, $oauthVersion',
      "Content-Type": "application/json"
    }).timeout(Duration(seconds: 15));
  }

  Future<User> getUser(String tag) async {
    String base = '/1.1/users/show.json';
    final response = await _twitterGet(base, [
      ["screen_name", tag],
      ["tweet_mode", "extended"]
    ]);

    if (response.statusCode == 200) {
      try {
        return User(json.decode(response.body));
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      print("Error retrieving user");
      print(response.body);
      return null;
    }
  }

  Future<List<Tweet>> getTimeline() async {
    String base = '/1.1/statuses/home_timeline.json';
    final response = await _twitterGet(base, [
      ["count", "200"],
      ["exclude_replies", "false"],
      ["tweet_mode", "extended"]
    ]);

    if (response.statusCode == 200) {
      var timeline = List<Tweet>();
      json.decode(response.body).forEach((map) => timeline.add(new Tweet(map)));
      return timeline;
    } else {
      print("Error retrieving new tweets");
      print(response.body);
      return null;
    }
  }

  Future<List<Tweet>> getUserTimeline(String tag) async {
    String base = '/1.1/statuses/user_timeline.json';
    final response = await _twitterGet(base, [
      ["screen_name", tag],
      ["tweet_mode", "extended"]
    ]);

    if (response.statusCode == 200) {
      List<Tweet> timeline = List();
      json.decode(response.body).forEach((data) => timeline.add(Tweet(data)));
      return timeline;
    } else
      return null;
  }

  Future<List<Tweet>> getMentions() async {
    String base = '/1.1/statuses/mentions_timeline.json';
    final response = await _twitterGet(base, [
      ["count", "200"],
      ["tweet_mode", "extended"]
    ]);

    if (response.statusCode == 200) {
      List<Tweet> timeline = List();
      json.decode(response.body).forEach((data) => timeline.add(Tweet(data)));
      return timeline;
    } else
      return null;
  }

  Future<Tweet> getTweet(int id) async {
    String base = "/1.1/statuses/show.json";
    final response = await _twitterGet(base, [
      ["id", id.toString()],
      ["tweet_mode", "extended"]
    ]);

    if (response.statusCode == 200) {
      return Tweet(json.decode(response.body));
    } else
      return null;
  }

  Future<List<Tweet>> getReplies(String query, int sinceId,
      [int maxId = -1]) async {
    String base = '/1.1/search/tweets.json';
    final params = [
      ["q", query],
      ["since_id", sinceId.toString()],
      ["result_type", "recent"],
      ["count", "200"],
      ["tweet_mode", "extended"]
    ];

    if (maxId != -1) params.add(["max_id", maxId.toString()]);

    final response = await _twitterGet(base, params);

    if (response.statusCode == 200) {
      List<Tweet> search = List();
      final statuses = json.decode(response.body);
      statuses["statuses"].forEach((data) => search.add(Tweet(data)));
      return search;
    } else
      return null;
  }

  Future<List<User>> searchUsers(String query, [count = 100]) async {
    String base = '/1.1/users/search.json';
    final response = await _twitterGet(base, [
      ["q", query],
      ["count", count.toString()],
      ["include_entities", "false"]
    ]);

    if (response.statusCode == 200) {
      List<User> search = List();
      json.decode(response.body).forEach((data) => search.add(User(data)));
      return search;
    } else {
      print(response.body);
      return null;
    }
  }

  Future<List<Tweet>> searchTweets(String query, [count = 200]) async {
    String base = '/1.1/search/tweets.json';
    final response = await _twitterGet(base, [
      ["q", query],
      ["count", count.toString()],
      ["tweet_mode", "extended"]
    ]);

    if (response.statusCode == 200) {
      List<Tweet> search = List();
      final statuses = json.decode(response.body);
      statuses["statuses"].forEach((data) => search.add(Tweet(data)));
      return search;
    } else {
      print(response.body);
      return null;
    }
  }

  void tweet(String status) async {
    String base = '/1.1/statuses/update.json';
    var resp = await _twitterPost(base, [
      ["status", status]
    ]);
    print(resp.body.toString());
  }

  Future<Map> tweetPromo(String status) async {
    String base = '/1.1/statuses/update.json';
    var order = await _twitterPost(base, [
      ["status", status]
    ]);
    Map parsed = json.decode(order.body);
    return parsed;
  }

  Future<bool> tweetResponse(String status) async {
    return true;
  }

  void reply(String status, int replyId) async {
    String base = '/1.1/statuses/update.json';
    await _twitterPost(base, [
      ["in_reply_to_status_id", replyId.toString()],
      ["status", status]
    ]);
  }

  void tweetMedia(String status, String mediaIds) async {
    String base = '/1.1/statuses/update.json';
    await _twitterPost(base, [
      ["status", status],
      ["media_ids", mediaIds]
    ]);
  }

  void followUser(int id) async {
    String base = '/1.1/friendships/create.json';
    await _twitterPost(base, [
      ["user_id", id.toString()]
    ]);
  }

  void unfollowUser(int id) async {
    String base = '/1.1/friendships/destroy.json';
    await _twitterPost(base, [
      ["user_id", id.toString()]
    ]);
  }

  void favoriteTweet(int id) async {
    String base = '/1.1/favorites/create.json';
    await _twitterPost(base, [
      ["id", id.toString()]
    ]);
  }

  void unfavoriteTweet(int id) async {
    String base = '/1.1/favorites/destroy.json';
    await _twitterPost(base, [
      ["id", id.toString()]
    ]);
  }

  void retweet(int id) async {
    String base = '/1.1/statuses/retweet/$id.json';
    await _twitterPost(base, []);
  }

  void undoRetweet(int id) async {
    String base = '/1.1/statuses/unretweet/$id.json';
    await _twitterPost(base, []);
  }
}
