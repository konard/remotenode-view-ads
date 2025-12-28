import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/constants/app_constants.dart';
import 'withdrawal_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final user = userProvider.user;

    if (user == null) {
      return const EmptyStateDisplay(
        title: 'Not logged in',
        subtitle: 'Please log in to view your wallet',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => walletProvider.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance card
            _BalanceCard(
              balance: user.coinBalance,
              canWithdraw: user.coinBalance >= AppConstants.minWithdrawalCoins,
              onWithdrawPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WithdrawalScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Earned',
                    value: '${user.totalEarned}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Withdrawn',
                    value: '${user.totalWithdrawn}',
                    icon: Icons.account_balance,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending withdrawals
            if (walletProvider.pendingWithdrawals.isNotEmpty) ...[
              Text(
                'Pending Withdrawals',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...walletProvider.pendingWithdrawals.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WithdrawalCard(withdrawal: w),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Transaction history
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (walletProvider.transactions.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Show all transactions
                      _showAllTransactions(context, walletProvider.transactions);
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (walletProvider.transactions.isEmpty)
              const EmptyStateDisplay(
                title: 'No transactions yet',
                subtitle: 'Start watching ads to earn coins!',
                icon: Icons.receipt_long_outlined,
              )
            else
              ...walletProvider.transactions.take(10).map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TransactionCard(transaction: t),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showAllTransactions(
      BuildContext context, List<CoinTransaction> transactions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'All Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TransactionCard(transaction: transactions[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;
  final bool canWithdraw;
  final VoidCallback onWithdrawPressed;

  const _BalanceCard({
    required this.balance,
    required this.canWithdraw,
    required this.onWithdrawPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usdValue = balance * AppConstants.coinsToUsdRate;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedCoinDisplay(
                    coins: balance,
                    iconSize: 32,
                    fontSize: 28,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '\$${usdValue.toStringAsFixed(2)} USD',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canWithdraw ? onWithdrawPressed : null,
                  icon: const Icon(Icons.account_balance),
                  label: Text(canWithdraw
                      ? 'Withdraw to PayPal'
                      : 'Min ${AppConstants.minWithdrawalCoins} coins to withdraw'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final CoinTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = transaction.amount > 0;

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: isPositive ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaction.typeLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${isPositive ? '+' : ''}${transaction.amount}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isPositive ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.adReward:
        return Icons.play_circle;
      case TransactionType.dailyBonus:
        return Icons.card_giftcard;
      case TransactionType.streakBonus:
        return Icons.local_fire_department;
      case TransactionType.withdrawal:
        return Icons.account_balance;
      case TransactionType.referralBonus:
        return Icons.people;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _WithdrawalCard extends StatelessWidget {
  final Withdrawal withdrawal;

  const _WithdrawalCard({required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(withdrawal.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getStatusIcon(withdrawal.status),
            color: _getStatusColor(withdrawal.status),
            size: 20,
          ),
        ),
        title: Text(
          '\$${withdrawal.usdAmount.toStringAsFixed(2)} to PayPal',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              withdrawal.paypalEmail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (withdrawal.rejectionReason != null)
              Text(
                withdrawal.rejectionReason!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(withdrawal.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            withdrawal.statusLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getStatusColor(withdrawal.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return Colors.orange;
      case WithdrawalStatus.approved:
        return Colors.green;
      case WithdrawalStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(WithdrawalStatus status) {
    switch (status) {
      case WithdrawalStatus.pending:
        return Icons.hourglass_empty;
      case WithdrawalStatus.approved:
        return Icons.check_circle;
      case WithdrawalStatus.rejected:
        return Icons.cancel;
    }
  }
}
