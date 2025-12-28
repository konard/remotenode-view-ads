import 'dart:math';
import '../data/models/models.dart';

/// Service for generating mock data for the app
class MockDataService {
  static final Random _random = Random();

  /// Generate a list of mock ads
  static List<Ad> generateMockAds({int count = 10}) {
    final now = DateTime.now();
    final ads = <Ad>[];

    final adTemplates = [
      {
        'title': 'SuperMart - Weekly Deals',
        'description':
            'Discover amazing weekly deals at SuperMart! Save up to 50% on groceries.',
        'advertiser': 'SuperMart Inc.',
        'type': AdType.video,
      },
      {
        'title': 'TechGadget Pro',
        'description':
            'The future of smartphones is here. Experience TechGadget Pro.',
        'advertiser': 'TechCorp',
        'type': AdType.video,
      },
      {
        'title': 'FitLife App',
        'description':
            'Get fit with FitLife! Track your workouts and achieve your goals.',
        'advertiser': 'FitLife Inc.',
        'type': AdType.image,
      },
      {
        'title': 'Pizza Paradise',
        'description':
            'Order now and get 20% off your first pizza! Fresh & delicious.',
        'advertiser': 'Pizza Paradise',
        'type': AdType.image,
      },
      {
        'title': 'Car Insurance Pro',
        'description':
            'Save hundreds on car insurance. Get a free quote today!',
        'advertiser': 'InsureCo',
        'type': AdType.video,
      },
      {
        'title': 'Adventure Quest',
        'description':
            'Play the hit game everyone is talking about! Free to play.',
        'advertiser': 'GameStudio',
        'type': AdType.playable,
      },
      {
        'title': 'BankEasy Mobile',
        'description':
            'Banking made easy. Open an account in minutes with BankEasy.',
        'advertiser': 'BankEasy',
        'type': AdType.video,
      },
      {
        'title': 'Fashion Forward',
        'description':
            'New collection is here! Shop the latest trends at Fashion Forward.',
        'advertiser': 'Fashion Forward',
        'type': AdType.image,
      },
      {
        'title': 'Match Master',
        'description':
            'Try the addictive puzzle game! Match tiles and win prizes.',
        'advertiser': 'PuzzleGames Inc.',
        'type': AdType.playable,
      },
      {
        'title': 'Cloud Storage Plus',
        'description':
            'Store all your files securely. Get 100GB free for 30 days!',
        'advertiser': 'CloudTech',
        'type': AdType.video,
      },
      {
        'title': 'Coffee House Premium',
        'description':
            'Premium coffee delivered to your door. Try our subscription box.',
        'advertiser': 'Coffee House',
        'type': AdType.image,
      },
      {
        'title': 'Runner Rush',
        'description':
            'Run, jump, and collect coins in this exciting endless runner!',
        'advertiser': 'MobileGames Studio',
        'type': AdType.playable,
      },
      {
        'title': 'Travel Easy',
        'description':
            'Book your dream vacation today! Best prices guaranteed.',
        'advertiser': 'TravelEasy',
        'type': AdType.video,
      },
      {
        'title': 'Healthy Meals',
        'description':
            'Fresh, healthy meals delivered weekly. Start your meal plan today!',
        'advertiser': 'HealthyMeals Co.',
        'type': AdType.image,
      },
      {
        'title': 'Music Stream Pro',
        'description':
            'Unlimited music streaming. Get 3 months free with Pro subscription.',
        'advertiser': 'StreamMusic Inc.',
        'type': AdType.video,
      },
    ];

    for (int i = 0; i < count; i++) {
      final template = adTemplates[i % adTemplates.length];
      final minWatch = 10 + _random.nextInt(11); // 10-20 seconds
      final maxWatch = minWatch + 10 + _random.nextInt(11); // +10-20 seconds

      ads.add(Ad(
        id: 'ad_${now.millisecondsSinceEpoch}_$i',
        title: template['title'] as String,
        description: template['description'] as String,
        type: template['type'] as AdType,
        mediaUrl: 'https://example.com/ad_$i.mp4',
        thumbnailUrl: 'https://picsum.photos/seed/ad$i/400/300',
        minWatchTimeSeconds: minWatch,
        maxWatchTimeSeconds: maxWatch,
        advertiser: template['advertiser'] as String,
        createdAt: now.subtract(Duration(hours: _random.nextInt(72))),
      ));
    }

    return ads;
  }

  /// Generate mock leaderboard data
  static List<LeaderboardEntry> generateMockLeaderboard({
    int count = 50,
    String? currentUserId,
  }) {
    final entries = <LeaderboardEntry>[];

    final usernames = [
      'AdMaster',
      'CoinHunter',
      'WatchPro',
      'EarnerKing',
      'RewardSeeker',
      'AdViewer',
      'MoneyMaker',
      'CoinCollector',
      'ProWatcher',
      'BonusHunter',
      'StarEarner',
      'TopViewer',
      'AdExpert',
      'CoinMaster',
      'RewardPro',
      'WatchStar',
      'EarnerPro',
      'CoinKing',
      'AdHero',
      'ViewerPlus',
    ];

    for (int i = 0; i < count; i++) {
      final username = usernames[i % usernames.length] + (i ~/ 20 > 0 ? '${i ~/ 20}' : '');
      final baseEarnings = (count - i) * 1000;
      final variance = _random.nextInt(500);
      final isCurrentUser = currentUserId != null && i == 15; // Place current user at rank 16

      entries.add(LeaderboardEntry(
        id: 'user_$i',
        username: isCurrentUser ? 'You' : username,
        rank: i + 1,
        totalEarned: baseEarnings + variance,
        adsWatched: (baseEarnings + variance) ~/ 25,
        isCurrentUser: isCurrentUser,
      ));
    }

    return entries;
  }

  /// Generate random coin amount for ad reward
  static int generateAdReward() {
    return 5 + _random.nextInt(46); // 5-50 coins
  }

  /// Generate daily bonus amount with streak multiplier
  static int generateDailyBonus(int streakDays) {
    const baseBonus = 50;
    final multiplier = 1.0 + (streakDays * 0.1).clamp(0, 1.0); // Max 100% bonus
    return (baseBonus * multiplier).round();
  }

  /// Simulate withdrawal processing
  static Future<WithdrawalStatus> simulateWithdrawalProcessing() async {
    // Simulate processing time (1-3 seconds)
    await Future.delayed(Duration(seconds: 1 + _random.nextInt(3)));

    // 80% chance of approval
    return _random.nextDouble() < 0.8
        ? WithdrawalStatus.approved
        : WithdrawalStatus.rejected;
  }

  /// Get random rejection reason
  static String getRandomRejectionReason() {
    final reasons = [
      'Invalid PayPal email address',
      'Account verification required',
      'Suspicious activity detected',
      'Please contact support',
    ];
    return reasons[_random.nextInt(reasons.length)];
  }
}
