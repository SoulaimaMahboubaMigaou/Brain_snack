import 'package:brainsnack/database/database_helper.dart';
import 'package:brainsnack/models/leaderboard_entry.dart';
import 'package:brainsnack/models/quiz_result.dart';

class ResultService {
  ResultService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<QuizResult>> getHistoryForUser(int userId) =>
      _databaseHelper.getScoresForUser(userId);

  Future<List<LeaderboardEntry>> getAggregatedLeaderboard() =>
      _databaseHelper.getAggregatedLeaderboard();

  Future<QuizResult> saveResult(QuizResult result) async {
    final id = await _databaseHelper.insertScore(result);
    return result.copyWith(id: id);
  }

  Future<void> updateResult(QuizResult result) async {
    await _databaseHelper.updateScore(result);
  }

  Future<void> deleteResult(int id) async {
    await _databaseHelper.deleteScore(id);
  }
}
