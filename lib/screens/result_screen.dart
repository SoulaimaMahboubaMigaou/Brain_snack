import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brainsnack/models/category.dart';
import 'package:brainsnack/providers/quiz_provider.dart';
import 'package:brainsnack/screens/quiz_screen.dart';
import 'package:brainsnack/widgets/gradient_shell.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const routeName = '/result';

  @override
  Widget build(BuildContext context) {
    final category =
        ModalRoute.of(context)?.settings.arguments as QuizCategory?;
    final quizProvider = context.watch<QuizProvider>();
    final result = quizProvider.latestResult;

    if (result == null) {
      return const Scaffold(
        body: GradientShell(
          child: Center(child: Text('No result available yet.')),
        ),
      );
    }

    final percentage = (result.accuracy * 100).round();
    final summary = switch (percentage) {
      100 => 'Perfect run. You cleared every question in this fresh set.',
      >= 80 => 'Excellent pace. Your theme instincts are staying sharp.',
      >= 50 =>
        'Solid session. Another randomized round could push this much higher.',
      _ =>
        'New attempts bring new question mixes. Run it back and improve fast.',
    };
    final retryCategory = category ?? QuizCategory.byId(result.themeId);

    return Scaffold(
      body: GradientShell(
        child: SafeArea(
          bottom: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.popUntil(
                            context,
                            ModalRoute.withName('/'),
                          ),
                          icon: const Icon(Icons.close_rounded),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              colors:
                                  category?.gradient ??
                                  [
                                    const Color(0xFF1FC8A5),
                                    const Color(0xFF1178A7),
                                  ],
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 58,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                '${result.score}',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'points earned',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.86,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                result.badge,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Performance summary',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _SummaryTile(
                          label: 'Theme',
                          value: retryCategory.title,
                        ),
                        _SummaryTile(
                          label: 'Correct answers',
                          value:
                              '${result.correctAnswers}/${result.totalQuestions}',
                        ),
                        _SummaryTile(label: 'Accuracy', value: '$percentage%'),
                        _SummaryTile(label: 'Mood', value: summary),
                        const Spacer(),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              final quizProvider = context.read<QuizProvider>();
                              debugPrint(
                                'BrainSnack retry tapped for theme: ${retryCategory.id}',
                              );
                              quizProvider.resetQuiz(themeId: retryCategory.id);
                              debugPrint(
                                'BrainSnack navigating to QuizScreen after reset.',
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => const QuizScreen(),
                                  settings: RouteSettings(
                                    name: QuizScreen.routeName,
                                    arguments: retryCategory,
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1FC8A5),
                              foregroundColor: const Color(0xFF06111D),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Retry Quiz'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.popUntil(
                              context,
                              ModalRoute.withName('/'),
                            ),
                            child: const Text('Back to dashboard'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF122033),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
