import 'dart:convert';

import 'package:share_social_media_plugin/TweetModel/user.dart';

TweetStatuses tweetStatusesFromJson(String str) =>
    TweetStatuses.fromJson(json.decode(str));

String tweetStatusesToJson(TweetStatuses data) => json.encode(data.toJson());

class TweetStatuses {
  String? createdAt;
  String? idStr;
  String? text;
  String? source;
  bool? truncated;
  dynamic inReplyToStatusId;
  dynamic inReplyToStatusIdStr;
  dynamic inReplyToUserId;
  dynamic inReplyToUserIdStr;
  dynamic inReplyToScreenName;
  User? user;
  dynamic geo;
  dynamic coordinates;
  dynamic place;
  dynamic contributors;
  bool? isQuoteStatus;
  int? quoteCount;
  int? replyCount;
  int? retweetCount;
  int? favoriteCount;
  bool? favorited;
  bool? retweeted;
  bool? possiblySensitive;
  String? filterLevel;
  String? lang;

  TweetStatuses({
    this.createdAt,
    this.idStr,
    this.text,
    this.source,
    this.truncated,
    this.inReplyToStatusId,
    this.inReplyToStatusIdStr,
    this.inReplyToUserId,
    this.inReplyToUserIdStr,
    this.inReplyToScreenName,
    this.user,
    this.geo,
    this.coordinates,
    this.place,
    this.contributors,
    this.isQuoteStatus,
    this.quoteCount,
    this.replyCount,
    this.retweetCount,
    this.favoriteCount,
    this.favorited,
    this.retweeted,
    this.possiblySensitive,
    this.filterLevel,
    this.lang,
  });

  factory TweetStatuses.fromJson(Map<String, dynamic> json) => TweetStatuses(
        createdAt: json["created_at"],
        idStr: json["id_str"],
        text: json["text"],
        source: json["source"],
        truncated: json["truncated"],
        inReplyToStatusId: json["in_reply_to_status_id"],
        inReplyToStatusIdStr: json["in_reply_to_status_id_str"],
        inReplyToUserId: json["in_reply_to_user_id"],
        inReplyToUserIdStr: json["in_reply_to_user_id_str"],
        inReplyToScreenName: json["in_reply_to_screen_name"],
        geo: json["geo"],
        coordinates: json["coordinates"],
        place: json["place"],
        contributors: json["contributors"],
        isQuoteStatus: json["is_quote_status"],
        quoteCount: json["quote_count"],
        replyCount: json["reply_count"],
        retweetCount: json["retweet_count"],
        favoriteCount: json["favorite_count"],
        favorited: json["favorited"],
        retweeted: json["retweeted"],
        possiblySensitive: json["possibly_sensitive"],
        filterLevel: json["filter_level"],
        lang: json["lang"],
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt,
        "id_str": idStr,
        "text": text,
        "source": source,
        "truncated": truncated,
        "in_reply_to_status_id": inReplyToStatusId,
        "in_reply_to_status_id_str": inReplyToStatusIdStr,
        "in_reply_to_user_id": inReplyToUserId,
        "in_reply_to_user_id_str": inReplyToUserIdStr,
        "in_reply_to_screen_name": inReplyToScreenName,
        "geo": geo,
        "coordinates": coordinates,
        "place": place,
        "contributors": contributors,
        "is_quote_status": isQuoteStatus,
        "quote_count": quoteCount,
        "reply_count": replyCount,
        "retweet_count": retweetCount,
        "favorite_count": favoriteCount,
        "favorited": favorited,
        "retweeted": retweeted,
        "possibly_sensitive": possiblySensitive,
        "filter_level": filterLevel,
        "lang": lang,
      };
}

class Url {
  String? url;
  String? expandedUrl;
  String? displayUrl;
  List<int>? indices;
  Unwound? unwound;

  Url({
    this.url,
    this.expandedUrl,
    this.displayUrl,
    this.indices,
    this.unwound,
  });

  factory Url.fromJson(Map<String, dynamic> json) => Url(
        url: json["url"],
        expandedUrl: json["expanded_url"],
        displayUrl: json["display_url"],
        indices: List<int>.from(json["indices"].map((x) => x)),
        unwound:
            json["unwound"] == null ? null : Unwound.fromJson(json["unwound"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "expanded_url": expandedUrl,
        "display_url": displayUrl,
        "indices": List<dynamic>.from(indices!.map((x) => x)),
        "unwound": unwound == null ? null : unwound!.toJson(),
      };
}

class Unwound {
  String? url;
  int? status;
  String? title;
  String? description;

  Unwound({
    this.url,
    this.status,
    this.title,
    this.description,
  });

  factory Unwound.fromJson(Map<String, dynamic> json) => Unwound(
        url: json["url"],
        status: json["status"],
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "status": status,
        "title": title,
        "description": description,
      };
}

class Derived {
  List<Location>? locations;

  Derived({
    this.locations,
  });

  factory Derived.fromJson(Map<String, dynamic> json) => Derived(
        locations: List<Location>.from(
            json["locations"].map((x) => Location.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "locations": List<dynamic>.from(locations!.map((x) => x.toJson())),
      };
}

class Location {
  String? country;
  String? countryCode;
  String? locality;
  String? region;
  String? subRegion;
  String? fullName;
  Geo? geo;

  Location({
    this.country,
    this.countryCode,
    this.locality,
    this.region,
    this.subRegion,
    this.fullName,
    this.geo,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        country: json["country"],
        countryCode: json["country_code"],
        locality: json["locality"],
        region: json["region"],
        subRegion: json["sub_region"],
        fullName: json["full_name"],
        geo: Geo.fromJson(json["geo"]),
      );

  Map<String, dynamic> toJson() => {
        "country": country,
        "country_code": countryCode,
        "locality": locality,
        "region": region,
        "sub_region": subRegion,
        "full_name": fullName,
        "geo": geo!.toJson(),
      };
}

class Geo {
  List<double>? coordinates;
  String? type;

  Geo({
    this.coordinates,
    this.type,
  });

  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
        coordinates: List<double>.from(json["coordinates"].map((x) => 0.0)),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": List<dynamic>.from(coordinates!.map((x) => x)),
        "type": type,
      };
}
