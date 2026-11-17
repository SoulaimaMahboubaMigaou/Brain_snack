import 'package:flutter/foundation.dart';
import 'package:brainsnack/models/leaderboard_entry.dart';
import 'package:brainsnack/providers/auth_provider.dart';
import 'package:brainsnack/services/leaderboard_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  LeaderboardProvider({
    required LeaderboardService leaderboardService,
    required AuthProvider authProvider,
  }) : _leaderboardService = leaderboardService,
       _authProvider = authProvider;

  final LeaderboardService _leaderboardService;
  AuthProvider _authProvider;

  bool isLoading = false;
  String? errorMessage;
  List<LeaderboardEntry> entries = [];

  LeaderboardEntry? get currentUserEntry {
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      return null;
    }
    for (final entry in entries) {
      if (entry.userId == userId) {
        return entry;
      }
    }
    return null;
  }

  void attachAuth(AuthProvider authProvider) {
    final previousUserId = _authProvider.currentUser?.id;
    _authProvider = authProvider;
    if (previousUserId != _authProvider.currentUser?.id) {
      refresh();
    }
  }

  Future<void> refresh() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      entries = await _leaderboardService.getLeaderboard();
    } catch (_) {
      errorMessage = 'Unable to load the leaderboard right now.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
