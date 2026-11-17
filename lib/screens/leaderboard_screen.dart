import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brainsnack/models/leaderboard_entry.dart';
import 'package:brainsnack/providers/leaderboard_provider.dart';
import 'package:brainsnack/widgets/gradient_shell.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const routeName = '/leaderboard';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final currentUserEntry = provider.currentUserEntry;

    return Scaffold(
      body: GradientShell(
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          color: const Color(0xFF1FC8A5),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Global Leaderboard',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                currentUserEntry == null
                    ? 'Finish quizzes to enter the rankings.'
                    : 'You are ranked #${currentUserEntry.rank} with ${currentUserEntry.totalScore} total points.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 22),
              if (provider.isLoading && provider.entries.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.errorMessage != null)
                _LeaderboardMessage(
                  message: provider.errorMessage!,
                  buttonLabel: 'Retry',
                  onPressed: provider.refresh,
                )
              else if (provider.entries.isEmpty)
                const _LeaderboardMessage(
                  message:
                      'No rankings yet. Complete a quiz to create the first leaderboard entry.',
                )
              else ...[
                if (provider.entries.isNotEmpty)
                  _TopThree(entries: provider.entries.take(3).toList()),
                const SizedBox(height: 18),
                ...provider.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LeaderboardTile(
                      entry: entry,
                      isCurrentUser: currentUserEntry?.userId == entry.userId,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TopThree extends StatelessWidget {
  const _TopThree({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];

    return Row(
      children: List.generate(entries.length, (index) {
        final entry = entries[index];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == entries.length - 1 ? 0 : 12,
            ),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF122033),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Text(medals[index], style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 10),
                Text(
                  entry.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.totalScore} pts',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry, required this.isCurrentUser});

  final LeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF17304A)
            : const Color(0xFF122033),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF1FC8A5)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? '${entry.username} (You)' : entry.username,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best ${entry.bestScore} • ${entry.gamesPlayed} games • Avg ${entry.averageScore.toStringAsFixed(1)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            '${entry.totalScore}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardMessage extends StatelessWidget {
  const _LeaderboardMessage({
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF122033),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel!)),
          ],
        ],
      ),
    );
  }
}
