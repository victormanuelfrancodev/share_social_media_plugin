class User {
  int id;
  String tag = "loading";
  String name = "Albatross User";
  String profileUrl = "";
  String backgroundUrl = "";
  String quote;
  int tweetCount;
  int followerCount;
  int followingCount;

  /// Create user from JSON map
  ///
  /// @param items JSON map
  User(Map<String, dynamic> items) {
    id = items["id"];
    tag = items["screen_name"] ?? "loading";
    name = items["name"];
    profileUrl = items["profile_image_url_https"] ?? "";
    backgroundUrl = items["profile_banner_url"] ?? "";
    quote = items["description"];
    tweetCount = items["statuses_count"] ?? 0;
    followerCount = items["followers_count"];
    followingCount = items["friends_count"];
  }
}
