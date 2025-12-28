import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/models/models.dart';

/// Service for managing local storage using Hive and SharedPreferences
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance!;

  late Box<User> _userBox;
  late Box<CoinTransaction> _transactionsBox;
  late Box<Withdrawal> _withdrawalsBox;
  late SharedPreferences _prefs;

  StorageService._();

  /// Initialize storage service
  static Future<void> initialize() async {
    _instance = StorageService._();
    await _instance!._init();
  }

  Future<void> _init() async {
    await Hive.initFlutter();

    // Register Hive adapters
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(AdTypeAdapter());
    Hive.registerAdapter(AdAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CoinTransactionAdapter());
    Hive.registerAdapter(WithdrawalStatusAdapter());
    Hive.registerAdapter(WithdrawalAdapter());

    // Open boxes
    _userBox = await Hive.openBox<User>(AppConstants.userBoxKey);
    _transactionsBox =
        await Hive.openBox<CoinTransaction>(AppConstants.transactionsBoxKey);
    _withdrawalsBox =
        await Hive.openBox<Withdrawal>(AppConstants.withdrawalsBoxKey);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // User operations
  User? getUser() {
    return _userBox.get('current_user');
  }

  Future<void> saveUser(User user) async {
    await _userBox.put('current_user', user);
  }

  Future<void> deleteUser() async {
    await _userBox.delete('current_user');
  }

  // Transaction operations
  List<CoinTransaction> getTransactions() {
    return _transactionsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addTransaction(CoinTransaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
  }

  Future<void> clearTransactions() async {
    await _transactionsBox.clear();
  }

  // Withdrawal operations
  List<Withdrawal> getWithdrawals() {
    return _withdrawalsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addWithdrawal(Withdrawal withdrawal) async {
    await _withdrawalsBox.put(withdrawal.id, withdrawal);
  }

  Future<void> updateWithdrawal(Withdrawal withdrawal) async {
    await _withdrawalsBox.put(withdrawal.id, withdrawal);
  }

  Future<void> clearWithdrawals() async {
    await _withdrawalsBox.clear();
  }

  // Settings operations
  bool isDarkMode() {
    return _prefs.getBool(AppConstants.themeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(AppConstants.themeKey, value);
  }

  String getLanguage() {
    return _prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(AppConstants.languageKey, languageCode);
  }

  DateTime? getLastBonusClaim() {
    final timestamp = _prefs.getInt(AppConstants.lastBonusClaimKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> setLastBonusClaim(DateTime date) async {
    await _prefs.setInt(
        AppConstants.lastBonusClaimKey, date.millisecondsSinceEpoch);
  }

  int getStreakCount() {
    return _prefs.getInt(AppConstants.streakCountKey) ?? 0;
  }

  Future<void> setStreakCount(int count) async {
    await _prefs.setInt(AppConstants.streakCountKey, count);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _userBox.clear();
    await _transactionsBox.clear();
    await _withdrawalsBox.clear();
    await _prefs.clear();
  }
}
