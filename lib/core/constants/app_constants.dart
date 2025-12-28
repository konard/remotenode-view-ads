/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'View Ads';
  static const String appVersion = '1.0.0';

  // Ad watching
  static const int minWatchTimeSeconds = 10;
  static const int maxWatchTimeSeconds = 30;
  static const int minCoinsPerAd = 5;
  static const int maxCoinsPerAd = 50;

  // Withdrawal
  static const int minWithdrawalCoins = 5000;
  static const double coinsToUsdRate = 0.001; // 1000 coins = $1

  // Daily bonus
  static const int baseDailyBonus = 50;
  static const int streakBonusPerDay = 10; // percentage
  static const int maxStreakMultiplier = 100; // max 100% bonus

  // Leaderboard
  static const int leaderboardSize = 100;

  // Storage keys
  static const String userBoxKey = 'user_box';
  static const String transactionsBoxKey = 'transactions_box';
  static const String withdrawalsBoxKey = 'withdrawals_box';
  static const String settingsBoxKey = 'settings_box';

  // Shared preferences keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String lastBonusClaimKey = 'last_bonus_claim';
  static const String streakCountKey = 'streak_count';
}
