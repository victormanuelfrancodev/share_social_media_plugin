import 'package:intl/intl.dart';

class Tweet {
  int id = -1;
  String source = 'Template';
  String tag = '@username';
  String fullName = 'Full Name';
  bool verified = false;
  String profileUrl;
  String body;
  bool favorited;
  int favoriteCount;
  bool retweeted;
  int retweetCount;
  int timestamp;
  String images = "";
  bool isRetweet = false;
  bool isQuote = false;
  int replyToId;
  int originalId;
  String originalTag;
  String originalName;
  String originalProfileUrl;
  String originalBody;
  String originalImages;

  /// Creates blank Tweet to be used
  Tweet.template();

  /// Default constructor for JSON map
  Tweet(Map<String, dynamic> items) {
    id = items["id"];
    source = RegExp(">[A-Z.a-z ]*<").stringMatch(items["source"]) ?? "";
    source = source.length > 3 ? source.substring(1, source.length - 1) : "";
    var range = items["display_text_range"];
    body = items["full_text"].toString().substring(range[0], range[1]);
    favoriteCount = items["favorite_count"] ?? 0;
    retweetCount = items["retweet_count"] ?? 0;
    retweeted = items["retweeted"] ?? false;
    favorited = items["favorited"] ?? false;
    replyToId = items["in_reply_to_status_id"] ?? 0;

    try {
      String time = items["created_at"];
      time = time.substring(0, 19) + time.substring(25);
      timestamp = new DateFormat("EEE MMM dd HH:mm:ss yyyy")
          .parseUTC(time)
          .millisecondsSinceEpoch
          .abs();
    } catch (e) {}

    var user = (items["user"]) as Map<String, dynamic>;
    tag = user["screen_name"];
    fullName = user["name"];
    profileUrl = user["profile_image_url_https"];
    verified = user["verified"] ?? false;

    var retweetStatus = (items["retweeted_status"]) as Map<String, dynamic>;
    isRetweet = retweetStatus != null;

    if (isRetweet) {
      try {
        originalId = retweetStatus["id"] ?? 0;
        favoriteCount = retweetStatus["favorite_count"] ?? 0;
        originalBody = retweetStatus["full_text"];

        var originalUser = retweetStatus["user"];
        originalTag = originalUser["screen_name"];
        originalName = originalUser["name"];
        originalProfileUrl = originalUser["profile_image_url_https"];

        var originalEntities =
            (retweetStatus["entities"]) as Map<String, dynamic>;
        var originalMedia = (originalEntities["media"]) as List<dynamic>;

        List<String> originalMedias = List();

        if (originalMedia != null && originalMedia.isNotEmpty)
          originalMedia
              .forEach((item) => originalMedias.add(item["media_url_https"]));

        originalImages = originalMedias.join("::");
      } catch (e) {}
    }

    var quotedStatus = (items["quoted_status"]) as Map<String, dynamic>;
    isQuote = quotedStatus != null;

    if (isQuote) {
      try {
        originalId = quotedStatus["id"] ?? 0;
        originalBody = quotedStatus["full_text"];

        var originalUser = quotedStatus["user"];
        originalTag = originalUser["screen_name"];
        originalName = originalUser["name"];
        originalProfileUrl = originalUser["profile_image_url_https"];

        var originalEntities =
            (quotedStatus["entities"]) as Map<String, dynamic>;
        var originalMedia = (originalEntities["media"]) as List<dynamic>;

        List<String> originalMedias = List();

        if (originalMedia != null && originalMedia.isNotEmpty)
          originalMedia
              .forEach((item) => originalMedias.add(item["media_url_https"]));

        originalImages = originalMedias.join("::");
      } catch (e) {}
    }

    var entities = (items["entities"]) as Map<String, dynamic>;
    var urls = (entities["urls"] as List<dynamic>);
    var media = (entities["media"] as List<dynamic>);

    try {
      if (urls != null && urls.isNotEmpty)
        urls.forEach(
            (url) => body = body.replaceFirst(url["url"], url["expanded_url"]));
    } catch (e) {
      print(e);
    }

    List<String> medias = List();

    if (media != null && media.isNotEmpty)
      media.forEach((item) => medias.add(item["media_url_https"]));

    images = medias.join("::");
  }

  String _formatText(String full) {
    String addLinks(String formatted) {
      final matches = RegExp(
              "https?://(www\\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_+.~#?&/=]*)",
              caseSensitive: false)
          .allMatches(full);

      for (final match in matches) {
        final fullLink = full.substring(match.start, match.end);
        var link = fullLink;
        final start = full.indexOf(link);
        final end = start + link.length;

        if (link.length > 40) {
          if (link.startsWith("https://"))
            link = link.substring("https://".length);
          else if (link.startsWith("http://"))
            link = link.substring("http://".length);

          if (link.startsWith("www.")) link = link.substring("www.".length);

          if (link.length > 40) link = '${link.substring(0, 40)}…';
        }

        formatted =
            formatted.replaceRange(start, end, '<a href="$fullLink">$link</a>');
      }

      return formatted;
    }

    String addMentions(String formatted) {
      final matches =
          RegExp("(@[A-Za-z0-9_]+)", caseSensitive: false).allMatches(full);

      for (final match in matches) {
        final fullLink = full.substring(match.start, match.end);
        final start = full.indexOf(fullLink);
        final end = start + fullLink.length;

        formatted = formatted.replaceRange(
            start, end, '<a href="$fullLink">$fullLink</a>');
      }

      return formatted;
    }

    String addTags(String formatted) {
      final matches =
          RegExp("(#[A-Za-z0-9_]+)", caseSensitive: false).allMatches(full);

      for (final match in matches) {
        final fullLink = full.substring(match.start, match.end);
        final start = full.indexOf(fullLink);
        final end = start + fullLink.length;

        formatted = formatted.replaceRange(
            start, end, '<a href="$fullLink">$fullLink</a>');
      }

      return formatted;
    }

    var formatted = full;
    formatted = addLinks(formatted);
    formatted = addMentions(formatted);
    formatted = addTags(formatted);
    return formatted;
  }

  String getFormattedBody() {
    return _formatText(body);
  }

  /// Method to format
  String getFormattedOriginBody() {
    return _formatText(originalBody);
  }

  /// Get users Twitter URL
  String getUrl() {
    return 'https://twitter.com/$tag/status/$id';
  }
}
