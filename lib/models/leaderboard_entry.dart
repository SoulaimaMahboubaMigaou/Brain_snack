class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.rank,
    required this.totalScore,
    required this.bestScore,
    required this.gamesPlayed,
    required this.averageScore,
  });

  final int userId;
  final String username;
  final int rank;
  final int totalScore;
  final int bestScore;
  final int gamesPlayed;
  final double averageScore;

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['user_id'] as int,
      username: map['username'] as String,
      rank: map['rank'] as int,
      totalScore: map['total_score'] as int,
      bestScore: map['best_score'] as int,
      gamesPlayed: map['games_played'] as int,
      averageScore: (map['average_score'] as num).toDouble(),
    );
  }
}
