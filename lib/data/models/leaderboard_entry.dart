/// Represents a leaderboard entry for rankings
class LeaderboardEntry {
  final String id;
  final String username;
  final int rank;
  final int totalEarned;
  final int adsWatched;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.id,
    required this.username,
    required this.rank,
    required this.totalEarned,
    required this.adsWatched,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    String? id,
    String? username,
    int? rank,
    int? totalEarned,
    int? adsWatched,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      username: username ?? this.username,
      rank: rank ?? this.rank,
      totalEarned: totalEarned ?? this.totalEarned,
      adsWatched: adsWatched ?? this.adsWatched,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'rank': rank,
      'totalEarned': totalEarned,
      'adsWatched': adsWatched,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String,
      username: json['username'] as String,
      rank: json['rank'] as int,
      totalEarned: json['totalEarned'] as int,
      adsWatched: json['adsWatched'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
    );
  }
}
