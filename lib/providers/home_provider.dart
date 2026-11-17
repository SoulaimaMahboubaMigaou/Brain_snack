import 'package:brainsnack/models/category.dart';
import 'package:brainsnack/models/leaderboard_entry.dart';
import 'package:brainsnack/models/quiz_result.dart';
import 'package:brainsnack/providers/auth_provider.dart';
import 'package:brainsnack/services/result_service.dart';
import 'package:flutter/foundation.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required ResultService resultService,
    required AuthProvider authProvider,
  }) : _resultService = resultService,
       _authProvider = authProvider;

  final ResultService _resultService;
  AuthProvider _authProvider;

  bool isLoading = false;
  String? errorMessage;
  List<QuizResult> history = [];
  List<LeaderboardEntry> leaderboard = [];
  QuizCategory dailyChallenge = QuizCategory.all.first;

  LeaderboardEntry? get currentUserLeaderboardEntry {
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      return null;
    }
    for (final entry in leaderboard) {
      if (entry.userId == userId) {
        return entry;
      }
    }
    return null;
  }

  int get streakCount {
    if (history.isEmpty) {
      return 0;
    }

    var streak = 1;
    var previous = history.first.completedAt;
    for (final result in history.skip(1)) {
      final difference = previous.difference(result.completedAt).inDays;
      if (difference <= 1) {
        streak++;
        previous = result.completedAt;
      } else {
        break;
      }
    }
    return streak;
  }

  int get bestScore => history.isEmpty
      ? 0
      : history.map((result) => result.score).reduce((a, b) => a > b ? a : b);

  void attachAuth(AuthProvider authProvider) {
    final previousUserId = _authProvider.currentUser?.id;
    _authProvider = authProvider;
    if (previousUserId != _authProvider.currentUser?.id) {
      refresh();
    }
  }

  Future<void> initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    final user = _authProvider.currentUser;
    if (user?.id == null) {
      history = [];
      leaderboard = [];
      isLoading = false;
      errorMessage = null;
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      history = await _resultService.getHistoryForUser(user!.id!);
      leaderboard = await _resultService.getAggregatedLeaderboard();
      dailyChallenge =
          QuizCategory.all[DateTime.now().day % (QuizCategory.all.length - 1)];
    } catch (_) {
      errorMessage = 'Unable to load your progress right now.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteResult(int id) async {
    await _resultService.deleteResult(id);
    await refresh();
  }
}
