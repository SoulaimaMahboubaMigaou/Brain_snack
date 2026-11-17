import 'package:brainsnack/database/database_helper.dart';
import 'package:brainsnack/models/leaderboard_entry.dart';

class LeaderboardService {
  LeaderboardService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<LeaderboardEntry>> getLeaderboard() {
    return _databaseHelper.getAggregatedLeaderboard();
  }
}
