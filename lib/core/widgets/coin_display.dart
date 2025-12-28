import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget for displaying coin balance with animation
class CoinDisplay extends StatelessWidget {
  final int coins;
  final double iconSize;
  final double fontSize;
  final bool showLabel;
  final Color? textColor;

  const CoinDisplay({
    super.key,
    required this.coins,
    this.iconSize = 24,
    this.fontSize = 18,
    this.showLabel = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.coinGold, AppTheme.coinDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.coinDark,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.monetization_on,
            size: iconSize * 0.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatCoins(coins),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            'coins',
            style: TextStyle(
              fontSize: fontSize * 0.8,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}

/// Animated coin display that shows change
class AnimatedCoinDisplay extends StatefulWidget {
  final int coins;
  final double iconSize;
  final double fontSize;

  const AnimatedCoinDisplay({
    super.key,
    required this.coins,
    this.iconSize = 24,
    this.fontSize = 18,
  });

  @override
  State<AnimatedCoinDisplay> createState() => _AnimatedCoinDisplayState();
}

class _AnimatedCoinDisplayState extends State<AnimatedCoinDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCoins = 0;

  @override
  void initState() {
    super.initState();
    _previousCoins = widget.coins;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedCoinDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coins != _previousCoins) {
      _controller.forward().then((_) => _controller.reverse());
      _previousCoins = widget.coins;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: CoinDisplay(
        coins: widget.coins,
        iconSize: widget.iconSize,
        fontSize: widget.fontSize,
      ),
    );
  }
}
