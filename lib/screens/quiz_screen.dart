import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brainsnack/models/category.dart';
import 'package:brainsnack/providers/home_provider.dart';
import 'package:brainsnack/providers/quiz_provider.dart';
import 'package:brainsnack/screens/result_screen.dart';
import 'package:brainsnack/widgets/answer_option.dart';
import 'package:brainsnack/widgets/gradient_shell.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  static const routeName = '/quiz';

  @override
  Widget build(BuildContext context) {
    final category =
        ModalRoute.of(context)?.settings.arguments as QuizCategory?;
    final quizProvider = context.watch<QuizProvider>();
    final question = quizProvider.currentQuestion;

    if (category != null &&
        !quizProvider.isLoading &&
        quizProvider.errorMessage == null &&
        quizProvider.questions.isEmpty &&
        !quizProvider.quizCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint(
          'BrainSnack QuizScreen auto-start for theme: ${category.id}',
        );
        context.read<QuizProvider>().startQuiz(category.id);
      });
    }

    if (quizProvider.quizCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<HomeProvider>().refresh();
        if (!context.mounted) {
          return;
        }
        Navigator.pushReplacementNamed(
          context,
          ResultScreen.routeName,
          arguments: category,
        );
      });
    }

    return Scaffold(
      body: GradientShell(
        child: quizProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : quizProvider.errorMessage != null
            ? _QuizErrorState(category: category)
            : question == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category?.title ?? 'Quiz',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'Live API set • Question ${quizProvider.currentIndex + 1}/${quizProvider.questions.length}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh quiz',
                          onPressed: category == null
                              ? null
                              : () {
                                  debugPrint(
                                    'BrainSnack manual refresh from QuizScreen for ${category.id}',
                                  );
                                  context.read<QuizProvider>().startQuiz(
                                    category.id,
                                  );
                                },
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${quizProvider.timeRemaining}s',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: quizProvider.progress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF1FC8A5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(question.id),
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF122033),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${question.difficulty.toUpperCase()} • ${category?.title ?? 'Mixed'}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: const Color(0xFFFFC75F)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question.prompt,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Score: ${quizProvider.score}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: question.options.map((option) {
                          return AnswerOption(
                            label: option,
                            isSelected: quizProvider.selectedAnswer == option,
                            isCorrect: option == question.correctAnswer,
                            isLocked: quizProvider.hasAnswered,
                            onTap: () => context
                                .read<QuizProvider>()
                                .selectAnswer(option),
                          );
                        }).toList(),
                      ),
                    ),
                    if (quizProvider.hasAnswered) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          question.explanation,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: quizProvider.hasAnswered
                            ? () => context.read<QuizProvider>().nextQuestion()
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1FC8A5),
                          foregroundColor: const Color(0xFF06111D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          quizProvider.currentIndex ==
                                  quizProvider.questions.length - 1
                              ? 'Finish quiz'
                              : 'Next question',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _QuizErrorState extends StatelessWidget {
  const _QuizErrorState({required this.category});

  final QuizCategory? category;

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF122033),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Color(0xFFFFC75F),
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load quiz',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                quizProvider.errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: category == null
                    ? null
                    : () {
                        debugPrint(
                          'BrainSnack error-state retry for theme: ${category!.id}',
                        );
                        context.read<QuizProvider>().startQuiz(category!.id);
                      },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
