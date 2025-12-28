import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/widgets/widgets.dart';
import 'ad_viewer_screen.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adsProvider = context.watch<AdsProvider>();

    if (adsProvider.isLoading) {
      return const LoadingIndicator(message: 'Loading ads...');
    }

    if (adsProvider.error != null) {
      return ErrorDisplay(
        message: adsProvider.error,
        onRetry: () => adsProvider.refreshAds(),
      );
    }

    final unwatchedAds = adsProvider.unwatchedAds;
    final watchedAds = adsProvider.watchedAds;

    return RefreshIndicator(
      onRefresh: () => adsProvider.refreshAds(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Unwatched ads section
          if (unwatchedAds.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Ads',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unwatchedAds.length} available',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...unwatchedAds.map((ad) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AdCard(ad: ad, isWatched: false),
                )),
            const SizedBox(height: 24),
          ],

          // Watched ads section
          if (watchedAds.isNotEmpty) ...[
            Text(
              'Completed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...watchedAds.map((ad) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AdCard(ad: ad, isWatched: true),
                )),
          ],

          // Empty state
          if (unwatchedAds.isEmpty && watchedAds.isEmpty)
            const EmptyStateDisplay(
              title: 'No ads available',
              subtitle: 'Check back later for more ads!',
              icon: Icons.play_circle_outline,
            ),
        ],
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final Ad ad;
  final bool isWatched;

  const _AdCard({required this.ad, required this.isWatched});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: isWatched
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdViewerScreen(ad: ad),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ad thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceContainerHighest,
                  gradient: isWatched
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.3),
                            theme.colorScheme.secondary.withOpacity(0.3),
                          ],
                        ),
                ),
                child: Center(
                  child: Icon(
                    _getAdTypeIcon(ad.type),
                    size: 32,
                    color: isWatched
                        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5)
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Ad info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getAdTypeColor(ad.type, theme)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ad.typeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getAdTypeColor(ad.type, theme),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isWatched) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isWatched
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ad.advertiser,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isWatched && ad.earnedCoins != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const CoinDisplay(
                            coins: 0,
                            iconSize: 16,
                            fontSize: 12,
                          ),
                          Text(
                            ' +${ad.earnedCoins}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (ad.userRating != null) ...[
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < ad.userRating!
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isWatched)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
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

  Color _getAdTypeColor(AdType type, ThemeData theme) {
    switch (type) {
      case AdType.video:
        return theme.colorScheme.primary;
      case AdType.image:
        return Colors.teal;
      case AdType.playable:
        return Colors.purple;
    }
  }
}
