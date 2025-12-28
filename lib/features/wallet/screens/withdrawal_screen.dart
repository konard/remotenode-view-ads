import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/widgets.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();

  int get _selectedAmount {
    return int.tryParse(_amountController.text) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    // Set default amount to minimum
    _amountController.text = AppConstants.minWithdrawalCoins.toString();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    final walletProvider = context.read<WalletProvider>();
    final amount = _selectedAmount;

    // Deduct coins from user
    final success = await userProvider.deductCoins(
      amount,
      description: 'Withdrawal request: $amount coins',
    );

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Request withdrawal
    final withdrawal = await walletProvider.requestWithdrawal(
      coinAmount: amount,
      paypalEmail: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (withdrawal != null) {
      final usdAmount = amount * AppConstants.coinsToUsdRate;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Withdrawal of \$${usdAmount.toStringAsFixed(2)} submitted!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (walletProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user;
    final walletProvider = context.watch<WalletProvider>();
    final maxAmount = user?.coinBalance ?? 0;
    final usdValue = _selectedAmount * AppConstants.coinsToUsdRate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
      ),
      body: LoadingOverlay(
        isLoading: walletProvider.isProcessing,
        message: 'Processing...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Available balance
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Available Balance',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedCoinDisplay(
                          coins: maxAmount,
                          iconSize: 28,
                          fontSize: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(maxAmount * AppConstants.coinsToUsdRate).toStringAsFixed(2)} USD',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // PayPal email
                Text(
                  'PayPal Email',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your PayPal email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PayPal email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Amount
                Text(
                  'Amount to Withdraw',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount in coins',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    suffixText: 'coins',
                    helperText: 'Min: ${AppConstants.minWithdrawalCoins} coins',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount < AppConstants.minWithdrawalCoins) {
                      return 'Minimum is ${AppConstants.minWithdrawalCoins} coins';
                    }
                    if (amount > maxAmount) {
                      return 'Exceeds available balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quick amount buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickAmountButton(
                      amount: AppConstants.minWithdrawalCoins,
                      isSelected:
                          _selectedAmount == AppConstants.minWithdrawalCoins,
                      onTap: () {
                        _amountController.text =
                            AppConstants.minWithdrawalCoins.toString();
                        setState(() {});
                      },
                    ),
                    _QuickAmountButton(
                      amount: 10000,
                      isSelected: _selectedAmount == 10000,
                      enabled: maxAmount >= 10000,
                      onTap: () {
                        _amountController.text = '10000';
                        setState(() {});
                      },
                    ),
                    _QuickAmountButton(
                      amount: 25000,
                      isSelected: _selectedAmount == 25000,
                      enabled: maxAmount >= 25000,
                      onTap: () {
                        _amountController.text = '25000';
                        setState(() {});
                      },
                    ),
                    _QuickAmountButton(
                      label: 'Max',
                      amount: maxAmount,
                      isSelected: _selectedAmount == maxAmount,
                      enabled: maxAmount >= AppConstants.minWithdrawalCoins,
                      onTap: () {
                        _amountController.text = maxAmount.toString();
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Conversion info
                Card(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Coins',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              _selectedAmount.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'You will receive',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${usdValue.toStringAsFixed(2)} USD',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rate: 1,000 coins = \$1.00 USD',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Submit button
                FilledButton(
                  onPressed: _submitWithdrawal,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('Request Withdrawal'),
                  ),
                ),
                const SizedBox(height: 16),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Withdrawals are typically processed within 1-3 business days.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String? label;
  final int amount;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _QuickAmountButton({
    this.label,
    required this.amount,
    required this.isSelected,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label ?? _formatAmount(amount),
            style: theme.textTheme.labelLarge?.copyWith(
              color: enabled
                  ? (isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant)
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return amount.toString();
  }
}
