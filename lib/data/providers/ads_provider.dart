import 'package:flutter/foundation.dart';
import '../../services/mock_data_service.dart';
import '../models/models.dart';

/// Provider for managing ads state
class AdsProvider extends ChangeNotifier {
  List<Ad> _ads = [];
  bool _isLoading = false;
  String? _error;
  Ad? _currentAd;

  List<Ad> get ads => _ads;
  List<Ad> get unwatchedAds => _ads.where((ad) => !ad.isWatched).toList();
  List<Ad> get watchedAds => _ads.where((ad) => ad.isWatched).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  Ad? get currentAd => _currentAd;

  AdsProvider() {
    loadAds();
  }

  /// Load ads from mock data
  Future<void> loadAds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      _ads = MockDataService.generateMockAds(count: 15);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load ads: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh ads
  Future<void> refreshAds() async {
    await loadAds();
  }

  /// Set current ad for viewing
  void setCurrentAd(Ad ad) {
    _currentAd = ad;
    notifyListeners();
  }

  /// Mark ad as watched
  void markAdAsWatched(String adId, int earnedCoins) {
    final index = _ads.indexWhere((ad) => ad.id == adId);
    if (index != -1) {
      _ads[index] = _ads[index].copyWith(
        isWatched: true,
        earnedCoins: earnedCoins,
      );
      if (_currentAd?.id == adId) {
        _currentAd = _ads[index];
      }
      notifyListeners();
    }
  }

  /// Rate ad
  void rateAd(String adId, int rating, {String? comment}) {
    final index = _ads.indexWhere((ad) => ad.id == adId);
    if (index != -1) {
      _ads[index] = _ads[index].copyWith(
        userRating: rating,
        userComment: comment,
      );
      if (_currentAd?.id == adId) {
        _currentAd = _ads[index];
      }
      notifyListeners();
    }
  }

  /// Get next unwatched ad
  Ad? getNextUnwatchedAd() {
    final unwatched = unwatchedAds;
    return unwatched.isNotEmpty ? unwatched.first : null;
  }

  /// Clear current ad
  void clearCurrentAd() {
    _currentAd = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
