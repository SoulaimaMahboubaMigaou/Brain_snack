import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:brainsnack/models/category.dart';
import 'package:brainsnack/models/question.dart';

class MockQuizApiService {
  MockQuizApiService({http.Client? client, Random? random})
    : _client = client ?? http.Client(),
      _random = random ?? Random();

  final http.Client _client;
  final Random _random;

  static const int _maxBackoffRetries = 6;
  static const Duration _requestTimeout = Duration(seconds: 12);
  static const Duration _postBackoffDelay = Duration(seconds: 12);

  Future<List<Question>> fetchQuestions(
    String themeId, {
    int count = 10,
  }) async {
    final uri = Uri.https('opentdb.com', '/api.php', {
      'amount': '$count',
      'type': 'multiple',
      if (_apiCategoryFor(themeId) != null)
        'category': '${_apiCategoryFor(themeId)}',
    });

    final response = await _fetchQuizWithRetry(uri);

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final responseCode = decoded['response_code'] as int? ?? -1;
    final results = decoded['results'] as List<dynamic>? ?? [];

    if (responseCode != 0 || results.isEmpty) {
      throw Exception('No quiz questions were returned from the API.');
    }

    return results.asMap().entries.map((entry) {
      return Question.fromApiJson(
        entry.value as Map<String, dynamic>,
        themeId: themeId == QuizCategory.randomMixedId
            ? QuizCategory.randomMixedId
            : themeId,
        index: entry.key,
        random: _random,
      );
    }).toList();
  }

  Future<http.Response> _fetchQuizWithRetry(Uri uri) async {
    var attempt = 0;

    while (true) {
      try {
        final response = await _client.get(uri).timeout(_requestTimeout);

        if (response.statusCode == 429) {
          attempt++;
          final delay = _retryDelayForAttempt(attempt);
          debugPrint(
            'BrainSnack quiz API rate-limited (429). Retry attempt $attempt in ${delay.inSeconds}s.',
          );
          await Future.delayed(delay);
          continue;
        }

        if (response.statusCode != 200) {
          throw Exception('Quiz API returned ${response.statusCode}.');
        }

        return response;
      } on http.ClientException catch (error) {
        throw Exception('Unable to reach the quiz API: ${error.message}');
      } on FormatException {
        rethrow;
      } on Exception {
        rethrow;
      }
    }
  }

  Duration _retryDelayForAttempt(int attempt) {
    if (attempt <= _maxBackoffRetries) {
      final seconds = 1 << (attempt - 1);
      return Duration(seconds: seconds);
    }

    debugPrint(
      'BrainSnack quiz API is still rate-limited after $_maxBackoffRetries retries. Continuing silent retry every ${_postBackoffDelay.inSeconds}s.',
    );
    return _postBackoffDelay;
  }

  int? _apiCategoryFor(String themeId) {
    switch (themeId) {
      case 'science':
        return 17;
      case 'math':
        return 19;
      case 'history':
        return 23;
      case 'sports':
        return 21;
      case 'technology':
        return 18;
      case 'movies':
        return 11;
      case QuizCategory.randomMixedId:
        return null;
      default:
        return null;
    }
  }
}
