import 'dart:math';

class Question {
  Question({
    required this.id,
    required this.themeId,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
  });

  final String id;
  final String themeId;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String difficulty;

  factory Question.fromApiJson(
    Map<String, dynamic> json, {
    required String themeId,
    required int index,
    Random? random,
  }) {
    final parsedCorrect = _decodeHtml(json['correct_answer'] as String);
    final parsedIncorrect = List<String>.from(
      json['incorrect_answers'] as List<dynamic>,
    ).map(_decodeHtml).toList();
    final parsedOptions = [...parsedIncorrect, parsedCorrect];
    parsedOptions.shuffle(random ?? Random());

    return Question(
      id: '${themeId}_$index',
      themeId: themeId,
      prompt: _decodeHtml(json['question'] as String),
      options: parsedOptions,
      correctAnswer: parsedCorrect,
      explanation: 'Correct answer: $parsedCorrect',
      difficulty: (json['difficulty'] as String?) ?? 'medium',
    );
  }

  static String _decodeHtml(String input) {
    return input
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&eacute;', 'e')
        .replaceAll('&uuml;', 'u')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&hellip;', '...')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }
}
