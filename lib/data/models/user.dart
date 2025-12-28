import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final bool isAnonymous;

  @HiveField(4)
  int coinBalance;

  @HiveField(5)
  int totalEarned;

  @HiveField(6)
  int totalWithdrawn;

  @HiveField(7)
  int adsWatched;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  int currentStreak;

  @HiveField(10)
  DateTime? lastBonusClaim;

  @HiveField(11)
  int rank;

  User({
    required this.id,
    this.email,
    required this.username,
    this.isAnonymous = false,
    this.coinBalance = 0,
    this.totalEarned = 0,
    this.totalWithdrawn = 0,
    this.adsWatched = 0,
    required this.createdAt,
    this.currentStreak = 0,
    this.lastBonusClaim,
    this.rank = 0,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    bool? isAnonymous,
    int? coinBalance,
    int? totalEarned,
    int? totalWithdrawn,
    int? adsWatched,
    DateTime? createdAt,
    int? currentStreak,
    DateTime? lastBonusClaim,
    int? rank,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      coinBalance: coinBalance ?? this.coinBalance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      adsWatched: adsWatched ?? this.adsWatched,
      createdAt: createdAt ?? this.createdAt,
      currentStreak: currentStreak ?? this.currentStreak,
      lastBonusClaim: lastBonusClaim ?? this.lastBonusClaim,
      rank: rank ?? this.rank,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'isAnonymous': isAnonymous,
      'coinBalance': coinBalance,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'adsWatched': adsWatched,
      'createdAt': createdAt.toIso8601String(),
      'currentStreak': currentStreak,
      'lastBonusClaim': lastBonusClaim?.toIso8601String(),
      'rank': rank,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      coinBalance: json['coinBalance'] as int? ?? 0,
      totalEarned: json['totalEarned'] as int? ?? 0,
      totalWithdrawn: json['totalWithdrawn'] as int? ?? 0,
      adsWatched: json['adsWatched'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastBonusClaim: json['lastBonusClaim'] != null
          ? DateTime.parse(json['lastBonusClaim'] as String)
          : null,
      rank: json['rank'] as int? ?? 0,
    );
  }
}
