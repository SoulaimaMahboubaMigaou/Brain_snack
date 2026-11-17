import 'dart:async';

import 'package:brainsnack/models/question.dart';
import 'package:brainsnack/models/quiz_result.dart';
import 'package:brainsnack/providers/auth_provider.dart';
import 'package:brainsnack/services/mock_quiz_api_service.dart';
import 'package:brainsnack/services/result_service.dart';
import 'package:flutter/foundation.dart';

class QuizProvider extends ChangeNotifier {
  QuizProvider({
    required MockQuizApiService apiService,
    required ResultService resultService,
    required AuthProvider authProvider,
  }) : _apiService = apiService,
       _resultService = resultService,
       _authProvider = authProvider;

  final MockQuizApiService _apiService;
  final ResultService _resultService;
  AuthProvider _authProvider;

  final int secondsPerQuestion = 20;

  bool isLoading = false;
  String? errorMessage;
  String? selectedThemeId;
  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  int correctAnswers = 0;
  String? selectedAnswer;
  bool hasAnswered = false;
  bool quizCompleted = false;
  int timeRemaining = 20;
  Timer? _timer;
  QuizResult? latestResult;

  Question? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length
      ? null
      : questions[currentIndex];

  double get progress =>
      questions.isEmpty ? 0 : (currentIndex + 1) / questions.length;

  void attachAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  void resetQuiz({String? themeId}) {
    debugPrint(
      'BrainSnack resetQuiz called for theme: ${themeId ?? selectedThemeId}',
    );
    _timer?.cancel();
    isLoading = false;
    errorMessage = null;
    selectedThemeId = themeId ?? selectedThemeId;
    questions = [];
    currentIndex = 0;
    score = 0;
    correctAnswers = 0;
    selectedAnswer = null;
    hasAnswered = false;
    quizCompleted = false;
    timeRemaining = secondsPerQuestion;
    latestResult = null;
    notifyListeners();
  }

  Future<void> startQuiz(String themeId) async {
    try {
      resetQuiz(themeId: themeId);
      isLoading = true;
      notifyListeners();

      questions = await _apiService.fetchQuestions(themeId, count: 10);
      _startTimer();
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(String answer) {
    if (hasAnswered || currentQuestion == null) {
      return;
    }

    hasAnswered = true;
    selectedAnswer = answer;
    _timer?.cancel();

    if (answer == currentQuestion!.correctAnswer) {
      correctAnswers++;
      score += 10;
    }

    notifyListeners();
  }

  Future<void> nextQuestion() async {
    if (currentQuestion == null) {
      return;
    }

    if (currentIndex == questions.length - 1) {
      await _completeQuiz();
      return;
    }

    currentIndex++;
    selectedAnswer = null;
    hasAnswered = false;
    _startTimer();
    notifyListeners();
  }

  Future<void> retryQuiz() async {
    final themeId = selectedThemeId;
    if (themeId == null) {
      return;
    }
    await startQuiz(themeId);
  }

  void _startTimer() {
    _timer?.cancel();
    timeRemaining = secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining == 0) {
        timer.cancel();
        hasAnswered = true;
        selectedAnswer = null;
        notifyListeners();
        return;
      }

      timeRemaining--;
      notifyListeners();
    });
  }

  Future<void> _completeQuiz() async {
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      errorMessage = 'You must be logged in to save a score.';
      notifyListeners();
      return;
    }

    _timer?.cancel();
    quizCompleted = true;
    final result = QuizResult(
      userId: userId,
      themeId: selectedThemeId ?? 'science',
      score: score,
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      completedAt: DateTime.now(),
      badge: _resolveBadge(),
    );

    latestResult = await _resultService.saveResult(result);
    notifyListeners();
  }

  String _resolveBadge() {
    final accuracy = questions.isEmpty ? 0 : correctAnswers / questions.length;
    if (accuracy == 1) {
      return 'Legend';
    }
    if (accuracy >= 0.8) {
      return 'Hot Streak';
    }
    if (accuracy >= 0.5) {
      return 'Quick Thinker';
    }
    return 'Fresh Start';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
