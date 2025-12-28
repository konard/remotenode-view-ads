import 'package:flutter/foundation.dart';
import '../../services/mock_data_service.dart';
import '../models/models.dart';

/// Time period filter for leaderboard
enum LeaderboardPeriod { thisWeek, thisMonth, allTime }

/// Provider for managing leaderboard state
class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  LeaderboardPeriod _period = LeaderboardPeriod.thisWeek;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<LeaderboardEntry> get entries => _entries;
  LeaderboardPeriod get period => _period;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get current user's entry
  LeaderboardEntry? get currentUserEntry =>
      _entries.where((e) => e.isCurrentUser).firstOrNull;

  LeaderboardProvider() {
    loadLeaderboard();
  }

  /// Set current user ID
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    loadLeaderboard();
  }

  /// Load leaderboard data
  Future<void> loadLeaderboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _entries = MockDataService.generateMockLeaderboard(
        count: 50,
        currentUserId: _currentUserId,
      );

      // Adjust earnings based on period
      if (_period == LeaderboardPeriod.thisWeek) {
        _entries = _entries
            .map((e) => e.copyWith(totalEarned: e.totalEarned ~/ 4))
            .toList();
      } else if (_period == LeaderboardPeriod.thisMonth) {
        _entries = _entries
            .map((e) => e.copyWith(totalEarned: e.totalEarned ~/ 2))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load leaderboard: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change time period
  void setPeriod(LeaderboardPeriod period) {
    if (_period != period) {
      _period = period;
      loadLeaderboard();
    }
  }

  /// Refresh leaderboard
  Future<void> refreshLeaderboard() async {
    await loadLeaderboard();
  }

  /// Get top N entries
  List<LeaderboardEntry> getTopEntries(int count) {
    return _entries.take(count).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
