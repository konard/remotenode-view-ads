import 'package:hive/hive.dart';

part 'ad.g.dart';

@HiveType(typeId: 1)
enum AdType {
  @HiveField(0)
  video,
  @HiveField(1)
  image,
  @HiveField(2)
  playable,
}

@HiveType(typeId: 2)
class Ad extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final AdType type;

  @HiveField(4)
  final String mediaUrl;

  @HiveField(5)
  final String thumbnailUrl;

  @HiveField(6)
  final int minWatchTimeSeconds;

  @HiveField(7)
  final int maxWatchTimeSeconds;

  @HiveField(8)
  final String advertiser;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  bool isWatched;

  @HiveField(11)
  int? userRating;

  @HiveField(12)
  String? userComment;

  @HiveField(13)
  int? earnedCoins;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.mediaUrl,
    required this.thumbnailUrl,
    this.minWatchTimeSeconds = 10,
    this.maxWatchTimeSeconds = 30,
    required this.advertiser,
    required this.createdAt,
    this.isWatched = false,
    this.userRating,
    this.userComment,
    this.earnedCoins,
  });

  String get typeLabel {
    switch (type) {
      case AdType.video:
        return 'Video Ad';
      case AdType.image:
        return 'Image Ad';
      case AdType.playable:
        return 'Playable Ad';
    }
  }

  Ad copyWith({
    String? id,
    String? title,
    String? description,
    AdType? type,
    String? mediaUrl,
    String? thumbnailUrl,
    int? minWatchTimeSeconds,
    int? maxWatchTimeSeconds,
    String? advertiser,
    DateTime? createdAt,
    bool? isWatched,
    int? userRating,
    String? userComment,
    int? earnedCoins,
  }) {
    return Ad(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      minWatchTimeSeconds: minWatchTimeSeconds ?? this.minWatchTimeSeconds,
      maxWatchTimeSeconds: maxWatchTimeSeconds ?? this.maxWatchTimeSeconds,
      advertiser: advertiser ?? this.advertiser,
      createdAt: createdAt ?? this.createdAt,
      isWatched: isWatched ?? this.isWatched,
      userRating: userRating ?? this.userRating,
      userComment: userComment ?? this.userComment,
      earnedCoins: earnedCoins ?? this.earnedCoins,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'minWatchTimeSeconds': minWatchTimeSeconds,
      'maxWatchTimeSeconds': maxWatchTimeSeconds,
      'advertiser': advertiser,
      'createdAt': createdAt.toIso8601String(),
      'isWatched': isWatched,
      'userRating': userRating,
      'userComment': userComment,
      'earnedCoins': earnedCoins,
    };
  }

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: AdType.values[json['type'] as int],
      mediaUrl: json['mediaUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      minWatchTimeSeconds: json['minWatchTimeSeconds'] as int? ?? 10,
      maxWatchTimeSeconds: json['maxWatchTimeSeconds'] as int? ?? 30,
      advertiser: json['advertiser'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isWatched: json['isWatched'] as bool? ?? false,
      userRating: json['userRating'] as int?,
      userComment: json['userComment'] as String?,
      earnedCoins: json['earnedCoins'] as int?,
    );
  }
}
