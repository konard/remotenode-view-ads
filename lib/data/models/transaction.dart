import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
enum TransactionType {
  @HiveField(0)
  adReward,
  @HiveField(1)
  dailyBonus,
  @HiveField(2)
  streakBonus,
  @HiveField(3)
  withdrawal,
  @HiveField(4)
  referralBonus,
}

@HiveType(typeId: 4)
class CoinTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final TransactionType type;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? relatedId; // Ad ID, withdrawal ID, etc.

  CoinTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.relatedId,
  });

  bool get isPositive => amount > 0;

  String get typeLabel {
    switch (type) {
      case TransactionType.adReward:
        return 'Ad Reward';
      case TransactionType.dailyBonus:
        return 'Daily Bonus';
      case TransactionType.streakBonus:
        return 'Streak Bonus';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.referralBonus:
        return 'Referral Bonus';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
    };
  }

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'] as String,
      type: TransactionType.values[json['type'] as int],
      amount: json['amount'] as int,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      relatedId: json['relatedId'] as String?,
    );
  }
}
