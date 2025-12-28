import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/mock_data_service.dart';

class AdViewerScreen extends StatefulWidget {
  final Ad ad;

  const AdViewerScreen({super.key, required this.ad});

  @override
  State<AdViewerScreen> createState() => _AdViewerScreenState();
}

class _AdViewerScreenState extends State<AdViewerScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _watchedSeconds = 0;
  bool _canSkip = false;
  bool _adCompleted = false;
  int _earnedCoins = 0;
  int _rating = 0;
  final _commentController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _earnedCoins = MockDataService.generateAdReward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _watchedSeconds++;
        if (_watchedSeconds >= widget.ad.minWatchTimeSeconds) {
          _canSkip = true;
        }
        if (_watchedSeconds >= widget.ad.maxWatchTimeSeconds) {
          _completeAd();
        }
      });
    });
  }

  void _completeAd() {
    _timer.cancel();
    setState(() {
      _adCompleted = true;
    });
  }

  Future<void> _submitRating() async {
    // Mark ad as watched
    context.read<AdsProvider>().markAdAsWatched(widget.ad.id, _earnedCoins);
    context.read<AdsProvider>().rateAd(
          widget.ad.id,
          _rating,
          comment:
              _commentController.text.isNotEmpty ? _commentController.text : null,
        );

    // Add coins to user
    await context.read<UserProvider>().addCoins(
          _earnedCoins,
          TransactionType.adReward,
          description: 'Watched ad: ${widget.ad.title}',
          relatedId: widget.ad.id,
        );

    // Refresh wallet data
    context.read<WalletProvider>().loadData();

    if (!mounted) return;

    // Show celebration and go back
    _showCelebration();
  }

  void _showCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CelebrationDialog(
        coins: _earnedCoins,
        onClose: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Go back to ads screen
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _commentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _watchedSeconds / widget.ad.maxWatchTimeSeconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _adCompleted ? _buildRatingScreen(theme) : _buildAdScreen(theme, progress),
      ),
    );
  }

  Widget _buildAdScreen(ThemeData theme, double progress) {
    return Column(
      children: [
        // Header with timer
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_canSkip)
                TextButton.icon(
                  onPressed: _completeAd,
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  label: const Text('Skip', style: TextStyle(color: Colors.white)),
                )
              else
                const SizedBox(width: 80),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_watchedSeconds}s / ${widget.ad.maxWatchTimeSeconds}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 80),
            ],
          ),
        ),

        // Progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),

        // Ad content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ad type icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Icon(
                      _getAdTypeIcon(widget.ad.type),
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  widget.ad.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.ad.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'by ${widget.ad.advertiser}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Reward preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CoinDisplay(
                        coins: 0,
                        iconSize: 24,
                        fontSize: 18,
                        textColor: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$_earnedCoins coins',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Skip info
        if (!_canSkip)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'You can skip in ${widget.ad.minWatchTimeSeconds - _watchedSeconds} seconds',
              style: TextStyle(color: Colors.white54),
            ),
          ),
      ],
    );
  }

  Widget _buildRatingScreen(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ad Completed!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '+$_earnedCoins coins',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Rating section
          Text(
            'Rate this ad',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Comment field
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a comment (optional)',
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _rating > 0 ? _submitRating : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('Submit & Collect Coins'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _rating = 3; // Default rating
              });
              _submitRating();
            },
            child: const Text(
              'Skip rating',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAdTypeIcon(AdType type) {
    switch (type) {
      case AdType.video:
        return Icons.play_circle;
      case AdType.image:
        return Icons.image;
      case AdType.playable:
        return Icons.games;
    }
  }
}

class _CelebrationDialog extends StatefulWidget {
  final int coins;
  final VoidCallback onClose;

  const _CelebrationDialog({required this.coins, required this.onClose});

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber[700]!,
                    Colors.orange[800]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: const Icon(
                      Icons.monetization_on,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+${widget.coins} coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Added to your balance!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
