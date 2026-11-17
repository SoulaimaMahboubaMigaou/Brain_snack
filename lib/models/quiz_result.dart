class QuizResult {
  const QuizResult({
    this.id,
    required this.userId,
    required this.themeId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
    required this.badge,
  });

  final int? id;
  final int userId;
  final String themeId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;
  final String badge;

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;

  QuizResult copyWith({
    int? id,
    int? userId,
    String? themeId,
    int? score,
    int? totalQuestions,
    int? correctAnswers,
    DateTime? completedAt,
    String? badge,
  }) {
    return QuizResult(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeId: themeId ?? this.themeId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      completedAt: completedAt ?? this.completedAt,
      badge: badge ?? this.badge,
    );
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      themeId: map['theme'] as String,
      score: map['score'] as int,
      totalQuestions: map['total_questions'] as int,
      correctAnswers: map['correct_answers'] as int,
      completedAt: DateTime.parse(map['date'] as String),
      badge: map['badge'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'theme': themeId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'date': completedAt.toIso8601String(),
      'badge': badge,
    };
  }
}
