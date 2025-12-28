import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../services/storage_service.dart';
import '../../services/mock_data_service.dart';
import '../models/models.dart';

/// Provider for managing user state
class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? true;

  final StorageService _storage = StorageService.instance;

  UserProvider() {
    _loadUser();
  }

  void _loadUser() {
    _user = _storage.getUser();
    notifyListeners();
  }

  /// Login with email
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For demo, accept any email/password combination
      if (email.isEmpty || password.length < 6) {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if user already exists
      final existingUser = _storage.getUser();
      if (existingUser != null && existingUser.email == email) {
        _user = existingUser;
      } else {
        // Create new user
        _user = User(
          id: const Uuid().v4(),
          email: email,
          username: email.split('@').first,
          isAnonymous: false,
          createdAt: DateTime.now(),
        );
        await _storage.saveUser(_user!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register with email
  Future<bool> registerWithEmail(
      String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Validate inputs
      if (email.isEmpty || !email.contains('@')) {
        _error = 'Invalid email address';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _error = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (username.isEmpty) {
        _error = 'Username is required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      _user = User(
        id: const Uuid().v4(),
        email: email,
        username: username,
        isAnonymous: false,
        createdAt: DateTime.now(),
      );
      await _storage.saveUser(_user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Continue as anonymous/guest user
  Future<bool> continueAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _user = User(
        id: const Uuid().v4(),
        username: 'Guest${DateTime.now().millisecondsSinceEpoch % 10000}',
        isAnonymous: true,
        createdAt: DateTime.now(),
      );
      await _storage.saveUser(_user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to continue as guest: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add coins to user balance
  Future<void> addCoins(int amount, TransactionType type,
      {String? description, String? relatedId}) async {
    if (_user == null) return;

    _user!.coinBalance += amount;
    _user!.totalEarned += amount;
    if (type == TransactionType.adReward) {
      _user!.adsWatched += 1;
    }

    await _storage.saveUser(_user!);

    // Record transaction
    final transaction = CoinTransaction(
      id: const Uuid().v4(),
      type: type,
      amount: amount,
      description: description ?? _getDefaultDescription(type, amount),
      createdAt: DateTime.now(),
      relatedId: relatedId,
    );
    await _storage.addTransaction(transaction);

    notifyListeners();
  }

  String _getDefaultDescription(TransactionType type, int amount) {
    switch (type) {
      case TransactionType.adReward:
        return 'Earned $amount coins from watching ad';
      case TransactionType.dailyBonus:
        return 'Daily bonus: $amount coins';
      case TransactionType.streakBonus:
        return 'Streak bonus: $amount coins';
      case TransactionType.withdrawal:
        return 'Withdrawal: -$amount coins';
      case TransactionType.referralBonus:
        return 'Referral bonus: $amount coins';
    }
  }

  /// Deduct coins from user balance
  Future<bool> deductCoins(int amount, {String? description}) async {
    if (_user == null) return false;
    if (_user!.coinBalance < amount) return false;

    _user!.coinBalance -= amount;
    _user!.totalWithdrawn += amount;

    await _storage.saveUser(_user!);

    // Record transaction
    final transaction = CoinTransaction(
      id: const Uuid().v4(),
      type: TransactionType.withdrawal,
      amount: -amount,
      description: description ?? 'Withdrawal: -$amount coins',
      createdAt: DateTime.now(),
    );
    await _storage.addTransaction(transaction);

    notifyListeners();
    return true;
  }

  /// Claim daily bonus
  Future<int?> claimDailyBonus() async {
    if (_user == null) return null;

    final lastClaim = _storage.getLastBonusClaim();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if bonus already claimed today
    if (lastClaim != null) {
      final lastClaimDay =
          DateTime(lastClaim.year, lastClaim.month, lastClaim.day);
      if (lastClaimDay == today) {
        return null; // Already claimed today
      }

      // Check streak
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastClaimDay == yesterday) {
        // Continue streak
        _user!.currentStreak += 1;
      } else {
        // Streak broken
        _user!.currentStreak = 1;
      }
    } else {
      _user!.currentStreak = 1;
    }

    // Calculate bonus with streak multiplier
    final bonus = MockDataService.generateDailyBonus(_user!.currentStreak);

    _user!.coinBalance += bonus;
    _user!.totalEarned += bonus;
    _user!.lastBonusClaim = now;

    await _storage.saveUser(_user!);
    await _storage.setLastBonusClaim(now);
    await _storage.setStreakCount(_user!.currentStreak);

    // Record transaction
    final transaction = CoinTransaction(
      id: const Uuid().v4(),
      type: TransactionType.dailyBonus,
      amount: bonus,
      description:
          'Daily bonus (Day ${_user!.currentStreak} streak): +$bonus coins',
      createdAt: now,
    );
    await _storage.addTransaction(transaction);

    notifyListeners();
    return bonus;
  }

  /// Check if daily bonus is available
  bool canClaimDailyBonus() {
    final lastClaim = _storage.getLastBonusClaim();
    if (lastClaim == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastClaimDay =
        DateTime(lastClaim.year, lastClaim.month, lastClaim.day);

    return lastClaimDay != today;
  }

  /// Get time until next bonus
  Duration getTimeUntilNextBonus() {
    final lastClaim = _storage.getLastBonusClaim();
    if (lastClaim == null) return Duration.zero;

    final now = DateTime.now();
    final nextBonus = DateTime(lastClaim.year, lastClaim.month, lastClaim.day)
        .add(const Duration(days: 1));

    if (now.isAfter(nextBonus)) return Duration.zero;
    return nextBonus.difference(now);
  }

  /// Update username
  Future<void> updateUsername(String username) async {
    if (_user == null) return;

    _user = _user!.copyWith(username: username);
    await _storage.saveUser(_user!);
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    await _storage.deleteUser();
    _user = null;
    notifyListeners();
  }

  /// Delete account
  Future<void> deleteAccount() async {
    await _storage.clearAllData();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
