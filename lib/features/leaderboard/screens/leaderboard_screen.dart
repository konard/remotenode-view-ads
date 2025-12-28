import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../../core/widgets/widgets.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leaderboardProvider = context.watch<LeaderboardProvider>();

    return Column(
      children: [
        // Period selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<LeaderboardPeriod>(
            segments: const [
              ButtonSegment(
                value: LeaderboardPeriod.thisWeek,
                label: Text('Week'),
                icon: Icon(Icons.calendar_view_week),
              ),
              ButtonSegment(
                value: LeaderboardPeriod.thisMonth,
                label: Text('Month'),
                icon: Icon(Icons.calendar_month),
              ),
              ButtonSegment(
                value: LeaderboardPeriod.allTime,
                label: Text('All Time'),
                icon: Icon(Icons.all_inclusive),
              ),
            ],
            selected: {leaderboardProvider.period},
            onSelectionChanged: (selected) {
              leaderboardProvider.setPeriod(selected.first);
            },
          ),
        ),

        // Leaderboard content
        Expanded(
          child: _buildContent(context, leaderboardProvider),
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, LeaderboardProvider leaderboardProvider) {
    if (leaderboardProvider.isLoading) {
      return const LoadingIndicator(message: 'Loading leaderboard...');
    }

    if (leaderboardProvider.error != null) {
      return ErrorDisplay(
        message: leaderboardProvider.error,
        onRetry: () => leaderboardProvider.refreshLeaderboard(),
      );
    }

    final entries = leaderboardProvider.entries;
    final currentUser = leaderboardProvider.currentUserEntry;

    return RefreshIndicator(
      onRefresh: () => leaderboardProvider.refreshLeaderboard(),
      child: CustomScrollView(
        slivers: [
          // Top 3 podium
          SliverToBoxAdapter(
            child: _TopThreePodium(
              entries: entries.take(3).toList(),
            ),
          ),

          // Current user rank (if not in top 3)
          if (currentUser != null && currentUser.rank > 3)
            SliverToBoxAdapter(
              child: _CurrentUserCard(entry: currentUser),
            ),

          // Rest of the list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = entries[index + 3];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LeaderboardEntryCard(entry: entry),
                  );
                },
                childCount: (entries.length - 3).clamp(0, entries.length),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _TopThreePodium({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (entries.length > 1)
            _PodiumItem(entry: entries[1], position: 2)
          else
            const SizedBox(width: 100),
          // 1st place
          if (entries.isNotEmpty) _PodiumItem(entry: entries[0], position: 1),
          // 3rd place
          if (entries.length > 2)
            _PodiumItem(entry: entries[2], position: 3)
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int position;

  const _PodiumItem({required this.entry, required this.position});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = position == 1 ? 140.0 : (position == 2 ? 110.0 : 90.0);
    final avatarSize = position == 1 ? 60.0 : 50.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for first place
        if (position == 1)
          Icon(
            Icons.workspace_premium,
            color: Colors.amber,
            size: 32,
          ),

        // Avatar with medal
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getMedalColor(position),
                  width: 3,
                ),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.3),
                    theme.colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  entry.username.isNotEmpty
                      ? entry.username[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: avatarSize * 0.4,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            // Medal
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getMedalColor(position),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getMedalColor(position).withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Username
        SizedBox(
          width: 100,
          child: Text(
            entry.username,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: entry.isCurrentUser ? theme.colorScheme.primary : null,
            ),
          ),
        ),

        // Earnings
        Text(
          '${_formatNumber(entry.totalEarned)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),

        // Podium stand
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getMedalColor(position),
                _getMedalColor(position).withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getMedalColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _CurrentUserCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _CurrentUserCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rank',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
                Text(
                  entry.username,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          CoinDisplay(
            coins: entry.totalEarned,
            textColor: theme.colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardEntryCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: entry.isCurrentUser ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: entry.isCurrentUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: entry.isCurrentUser
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        title: Text(
          entry.username,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color:
                entry.isCurrentUser ? theme.colorScheme.onPrimaryContainer : null,
          ),
        ),
        subtitle: Text(
          '${entry.adsWatched} ads watched',
          style: theme.textTheme.bodySmall?.copyWith(
            color: entry.isCurrentUser
                ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: CoinDisplay(
          coins: entry.totalEarned,
          fontSize: 14,
          iconSize: 18,
          textColor:
              entry.isCurrentUser ? theme.colorScheme.onPrimaryContainer : null,
        ),
      ),
    );
  }
}
