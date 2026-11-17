import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brainsnack/models/category.dart';
import 'package:brainsnack/providers/auth_provider.dart';
import 'package:brainsnack/providers/home_provider.dart';
import 'package:brainsnack/providers/quiz_provider.dart';
import 'package:brainsnack/screens/leaderboard_screen.dart';
import 'package:brainsnack/screens/login_screen.dart';
import 'package:brainsnack/screens/quiz_screen.dart';
import 'package:brainsnack/widgets/daily_challenge_card.dart';
import 'package:brainsnack/widgets/gradient_shell.dart';
import 'package:brainsnack/widgets/leaderboard_preview_tile.dart';
import 'package:brainsnack/widgets/score_history_tile.dart';
import 'package:brainsnack/widgets/stat_chip.dart';
import 'package:brainsnack/widgets/theme_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedThemeId;
  bool _isStartingQuiz = false;

  Future<void> _startQuiz(BuildContext context, QuizCategory category) async {
    if (_isStartingQuiz) {
      return;
    }

    setState(() {
      _isStartingQuiz = true;
      _selectedThemeId = category.id;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final quizProvider = context.read<QuizProvider>();
    await quizProvider.startQuiz(category.id);
    if (!mounted) {
      return;
    }

    if (quizProvider.errorMessage == null &&
        quizProvider.questions.isNotEmpty) {
      if (!context.mounted) {
        return;
      }
      await navigator.push(
        PageRouteBuilder<void>(
          settings: RouteSettings(
            name: QuizScreen.routeName,
            arguments: category,
          ),
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: const QuizScreen(),
            );
          },
        ),
      );
    } else if (mounted) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              quizProvider.errorMessage ?? 'Unable to load quiz right now.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isStartingQuiz = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          GradientShell(
            child: RefreshIndicator(
              onRefresh: homeProvider.refresh,
              color: const Color(0xFF1FC8A5),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${user?.username ?? 'Player'}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sharpen your brain with fast quiz bursts, track your progress, and keep climbing the ranks.',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white70,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            final authProvider = context.read<AuthProvider>();
                            final homeProvider = context.read<HomeProvider>();
                            final navigator = Navigator.of(context);

                            await authProvider.logout();
                            await homeProvider.refresh();
                            if (!context.mounted) {
                              return;
                            }
                            navigator.pushReplacementNamed(
                              LoginScreen.routeName,
                            );
                          },
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: StatChip(
                          label: 'Current streak',
                          value: '${homeProvider.streakCount} days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatChip(
                          label: 'Best score',
                          value: '${homeProvider.bestScore}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatChip(
                          label: 'Played',
                          value: '${homeProvider.history.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (homeProvider.currentUserLeaderboardEntry != null) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF122033),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF1FC8A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.leaderboard_rounded,
                            color: Color(0xFF1FC8A5),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You are ranked #${homeProvider.currentUserLeaderboardEntry!.rank} globally.',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              LeaderboardScreen.routeName,
                            ),
                            child: const Text('Open'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                  DailyChallengeCard(
                    category: homeProvider.dailyChallenge,
                    onTap: () =>
                        _startQuiz(context, homeProvider.dailyChallenge),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a theme',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Each theme launches a fresh 10-question live quiz set.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: QuizCategory.all.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.92,
                              ),
                          itemBuilder: (context, index) {
                            final category = QuizCategory.all[index];
                            return ThemeCard(
                              category: category,
                              isSelected: _selectedThemeId == category.id,
                              onTap: _isStartingQuiz
                                  ? () {}
                                  : () => _startQuiz(context, category),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Global leaderboard',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          LeaderboardScreen.routeName,
                        ),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (homeProvider.leaderboard.isEmpty)
                    const _EmptyPanel(
                      message:
                          'No scores yet. Be the first to put a number on the board.',
                    )
                  else
                    ...homeProvider.leaderboard.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LeaderboardPreviewTile(
                          entry: entry,
                          isCurrentUser:
                              homeProvider
                                  .currentUserLeaderboardEntry
                                  ?.userId ==
                              entry.userId,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Text(
                    'Your history',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (homeProvider.history.isEmpty)
                    const _EmptyPanel(
                      message:
                          'Your personal score history will appear after your first quiz.',
                    )
                  else
                    ...homeProvider.history.map(
                      (result) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScoreHistoryTile(
                          result: result,
                          onDelete: result.id == null
                              ? null
                              : () => homeProvider.deleteResult(result.id!),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_isStartingQuiz)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.32),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102033),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preparing your quiz...',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Loading fresh questions for ${QuizCategory.byId(_selectedThemeId ?? QuizCategory.all.first.id).title}.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF122033),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    );
  }
}
