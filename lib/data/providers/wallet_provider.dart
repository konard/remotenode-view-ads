import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../services/storage_service.dart';
import '../../services/mock_data_service.dart';
import '../models/models.dart';

/// Provider for managing wallet/withdrawal state
class WalletProvider extends ChangeNotifier {
  List<CoinTransaction> _transactions = [];
  List<Withdrawal> _withdrawals = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  List<CoinTransaction> get transactions => _transactions;
  List<Withdrawal> get withdrawals => _withdrawals;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  final StorageService _storage = StorageService.instance;

  WalletProvider() {
    loadData();
  }

  /// Load transactions and withdrawals from storage
  void loadData() {
    _transactions = _storage.getTransactions();
    _withdrawals = _storage.getWithdrawals();
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    loadData();

    _isLoading = false;
    notifyListeners();
  }

  /// Request withdrawal
  Future<Withdrawal?> requestWithdrawal({
    required int coinAmount,
    required String paypalEmail,
  }) async {
    if (coinAmount < AppConstants.minWithdrawalCoins) {
      _error =
          'Minimum withdrawal is ${AppConstants.minWithdrawalCoins} coins';
      notifyListeners();
      return null;
    }

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final usdAmount = coinAmount * AppConstants.coinsToUsdRate;

      final withdrawal = Withdrawal(
        id: const Uuid().v4(),
        coinAmount: coinAmount,
        usdAmount: usdAmount,
        paypalEmail: paypalEmail,
        status: WithdrawalStatus.pending,
        createdAt: DateTime.now(),
      );

      await _storage.addWithdrawal(withdrawal);
      _withdrawals.insert(0, withdrawal);

      // Simulate processing
      _simulateWithdrawalProcessing(withdrawal);

      _isProcessing = false;
      notifyListeners();
      return withdrawal;
    } catch (e) {
      _error = 'Withdrawal request failed: ${e.toString()}';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  /// Simulate withdrawal processing in background
  void _simulateWithdrawalProcessing(Withdrawal withdrawal) async {
    // Simulate processing delay (3-10 seconds for demo)
    await Future.delayed(const Duration(seconds: 5));

    final status = await MockDataService.simulateWithdrawalProcessing();
    final processedWithdrawal = withdrawal.copyWith(
      status: status,
      processedAt: DateTime.now(),
      rejectionReason: status == WithdrawalStatus.rejected
          ? MockDataService.getRandomRejectionReason()
          : null,
    );

    await _storage.updateWithdrawal(processedWithdrawal);

    // Update local list
    final index = _withdrawals.indexWhere((w) => w.id == withdrawal.id);
    if (index != -1) {
      _withdrawals[index] = processedWithdrawal;
      notifyListeners();
    }
  }

  /// Get pending withdrawals
  List<Withdrawal> get pendingWithdrawals =>
      _withdrawals.where((w) => w.status == WithdrawalStatus.pending).toList();

  /// Get completed withdrawals (approved or rejected)
  List<Withdrawal> get completedWithdrawals => _withdrawals
      .where((w) => w.status != WithdrawalStatus.pending)
      .toList();

  /// Calculate total USD amount from withdrawals
  double get totalWithdrawnUsd => _withdrawals
      .where((w) => w.status == WithdrawalStatus.approved)
      .fold(0, (sum, w) => sum + w.usdAmount);

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
