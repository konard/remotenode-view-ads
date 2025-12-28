import 'package:hive/hive.dart';

part 'withdrawal.g.dart';

@HiveType(typeId: 5)
enum WithdrawalStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
}

@HiveType(typeId: 6)
class Withdrawal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int coinAmount;

  @HiveField(2)
  final double usdAmount;

  @HiveField(3)
  final String paypalEmail;

  @HiveField(4)
  WithdrawalStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime? processedAt;

  @HiveField(7)
  String? rejectionReason;

  Withdrawal({
    required this.id,
    required this.coinAmount,
    required this.usdAmount,
    required this.paypalEmail,
    this.status = WithdrawalStatus.pending,
    required this.createdAt,
    this.processedAt,
    this.rejectionReason,
  });

  String get statusLabel {
    switch (status) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.approved:
        return 'Approved';
      case WithdrawalStatus.rejected:
        return 'Rejected';
    }
  }

  Withdrawal copyWith({
    String? id,
    int? coinAmount,
    double? usdAmount,
    String? paypalEmail,
    WithdrawalStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? rejectionReason,
  }) {
    return Withdrawal(
      id: id ?? this.id,
      coinAmount: coinAmount ?? this.coinAmount,
      usdAmount: usdAmount ?? this.usdAmount,
      paypalEmail: paypalEmail ?? this.paypalEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coinAmount': coinAmount,
      'usdAmount': usdAmount,
      'paypalEmail': paypalEmail,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] as String,
      coinAmount: json['coinAmount'] as int,
      usdAmount: (json['usdAmount'] as num).toDouble(),
      paypalEmail: json['paypalEmail'] as String,
      status: WithdrawalStatus.values[json['status'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
}
