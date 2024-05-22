// To parse this JSON data, do
//
//     final activity = activityFromJson(jsonString);

import 'dart:convert';

List<Activity> activityFromJson(String str) =>
    List<Activity>.from(json.decode(str).map((x) => Activity.fromJson(x)));

String activityToJson(List<Activity> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Activity {
  int userId;
  Component? component;
  Content content;
  DateTime date;
  DateTime dateGmt;
  int id;
  String link;
  int primaryItemId;
  int secondaryItemId;
  Status status;
  String title;
  Type? type;
  bool favorited;
  UserAvatar userAvatar;
  Links links;
  int? commentCount;
  List<Comment>? comments;

  Activity({
    required this.userId,
    required this.component,
    required this.content,
    required this.date,
    required this.dateGmt,
    required this.id,
    required this.link,
    required this.primaryItemId,
    required this.secondaryItemId,
    required this.status,
    required this.title,
    required this.type,
    required this.favorited,
    required this.userAvatar,
    required this.links,
    this.commentCount,
    this.comments,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        userId: json["user_id"],
        component: componentValues.map[json["component"]],
        content: Content.fromJson(json["content"]),
        date: DateTime.parse(json["date"]),
        dateGmt: DateTime.parse(json["date_gmt"]),
        id: json["id"],
        link: json["link"],
        primaryItemId: json["primary_item_id"],
        secondaryItemId: json["secondary_item_id"],
        status: statusValues.map[json["status"]]!,
        title: json["title"],
        type: typeValues.map[json["type"]],
        favorited: json["favorited"],
        userAvatar: UserAvatar.fromJson(json["user_avatar"]),
        links: Links.fromJson(json["_links"]),
        commentCount: json["comment_count"],
        comments: json["comments"] == null
            ? []
            : List<Comment>.from(
                json["comments"]!.map((x) => Comment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "component": componentValues.reverse[component],
        "content": content.toJson(),
        "date": date.toIso8601String(),
        "date_gmt": dateGmt.toIso8601String(),
        "id": id,
        "link": link,
        "primary_item_id": primaryItemId,
        "secondary_item_id": secondaryItemId,
        "status": statusValues.reverse[status],
        "title": title,
        "type": typeValues.reverse[type],
        "favorited": favorited,
        "user_avatar": userAvatar.toJson(),
        "_links": links.toJson(),
        "comment_count": commentCount,
        "comments": comments == null
            ? []
            : List<dynamic>.from(comments!.map((x) => x.toJson())),
      };
}

class Comment {
  int userId;
  Component component;
  Content content;
  DateTime date;
  DateTime dateGmt;
  int id;
  String link;
  int primaryItemId;
  int secondaryItemId;
  Status status;
  String title;
  String type;
  bool favorited;
  UserAvatar userAvatar;
  Links links;

  Comment({
    required this.userId,
    required this.component,
    required this.content,
    required this.date,
    required this.dateGmt,
    required this.id,
    required this.link,
    required this.primaryItemId,
    required this.secondaryItemId,
    required this.status,
    required this.title,
    required this.type,
    required this.favorited,
    required this.userAvatar,
    required this.links,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        userId: json["user_id"],
        component: componentValues.map[json["component"]]!,
        content: Content.fromJson(json["content"]),
        date: DateTime.parse(json["date"]),
        dateGmt: DateTime.parse(json["date_gmt"]),
        id: json["id"],
        link: json["link"],
        primaryItemId: json["primary_item_id"],
        secondaryItemId: json["secondary_item_id"],
        status: statusValues.map[json["status"]]!,
        title: json["title"],
        type: json["type"],
        favorited: json["favorited"],
        userAvatar: UserAvatar.fromJson(json["user_avatar"]),
        links: Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "component": componentValues.reverse[component],
        "content": content.toJson(),
        "date": date.toIso8601String(),
        "date_gmt": dateGmt.toIso8601String(),
        "id": id,
        "link": link,
        "primary_item_id": primaryItemId,
        "secondary_item_id": secondaryItemId,
        "status": statusValues.reverse[status],
        "title": title,
        "type": type,
        "favorited": favorited,
        "user_avatar": userAvatar.toJson(),
        "_links": links.toJson(),
      };
}

enum Component { ACTIVITY }

final componentValues = EnumValues({"activity": Component.ACTIVITY});

class Content {
  String rendered;

  Content({
    required this.rendered,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        rendered: json["rendered"],
      );

  Map<String, dynamic> toJson() => {
        "rendered": rendered,
      };
}

class Links {
  List<Collection> self;
  List<Collection> collection;
  List<User> user;
  List<Collection>? up;

  Links({
    required this.self,
    required this.collection,
    required this.user,
    this.up,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: List<Collection>.from(
            json["self"].map((x) => Collection.fromJson(x))),
        collection: List<Collection>.from(
            json["collection"].map((x) => Collection.fromJson(x))),
        user: List<User>.from(json["user"].map((x) => User.fromJson(x))),
        up: json["up"] == null
            ? []
            : List<Collection>.from(
                json["up"]!.map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": List<dynamic>.from(self.map((x) => x.toJson())),
        "collection": List<dynamic>.from(collection.map((x) => x.toJson())),
        "user": List<dynamic>.from(user.map((x) => x.toJson())),
        "up": up == null ? [] : List<dynamic>.from(up!.map((x) => x.toJson())),
      };
}

class Collection {
  String href;

  Collection({
    required this.href,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}

class User {
  bool embeddable;
  String href;

  User({
    required this.embeddable,
    required this.href,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        embeddable: json["embeddable"],
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "embeddable": embeddable,
        "href": href,
      };
}

enum Status { PUBLISHED }

final statusValues = EnumValues({"published": Status.PUBLISHED});

class UserAvatar {
  String full;
  String thumb;

  UserAvatar({
    required this.full,
    required this.thumb,
  });

  factory UserAvatar.fromJson(Map<String, dynamic> json) => UserAvatar(
        full: json["full"],
        thumb: json["thumb"],
      );

  Map<String, dynamic> toJson() => {
        "full": full,
        "thumb": thumb,
      };
}

enum Type { RTMEDIA_UPDATE }

final typeValues = EnumValues({"rtmedia_update": Type.RTMEDIA_UPDATE});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
