import 'package:flutter/material.dart';

class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  static const randomMixedId = 'random_mixed';

  static const all = [
    QuizCategory(
      id: 'science',
      title: 'Science',
      description: 'Nature, chemistry, space, and clever experiments.',
      icon: Icons.science_rounded,
      gradient: [Color(0xFF4FC3F7), Color(0xFF4361EE)],
    ),
    QuizCategory(
      id: 'math',
      title: 'Math',
      description: 'Numbers, logic, patterns, and mental speed.',
      icon: Icons.calculate_rounded,
      gradient: [Color(0xFF1FC8A5), Color(0xFF1178A7)],
    ),
    QuizCategory(
      id: 'history',
      title: 'History',
      description: 'Empires, turning points, and remarkable people.',
      icon: Icons.account_balance_rounded,
      gradient: [Color(0xFFFF9F1C), Color(0xFFF15BB5)],
    ),
    QuizCategory(
      id: 'sports',
      title: 'Sports',
      description: 'Champions, records, rules, and iconic moments.',
      icon: Icons.sports_soccer_rounded,
      gradient: [Color(0xFF43AA8B), Color(0xFF277DA1)],
    ),
    QuizCategory(
      id: 'technology',
      title: 'Technology',
      description: 'Devices, code, the internet, and innovation.',
      icon: Icons.memory_rounded,
      gradient: [Color(0xFF7B61FF), Color(0xFF4CC9F0)],
    ),
    QuizCategory(
      id: 'movies',
      title: 'Movies',
      description: 'Cinema, characters, directors, and blockbusters.',
      icon: Icons.movie_creation_rounded,
      gradient: [Color(0xFFFF6B6B), Color(0xFFFFC75F)],
    ),
    QuizCategory(
      id: randomMixedId,
      title: 'Random Mixed',
      description: 'A shuffle across every theme for true snack chaos.',
      icon: Icons.shuffle_rounded,
      gradient: [Color(0xFF9D4EDD), Color(0xFF00BBF9)],
    ),
  ];

  static QuizCategory byId(String id) {
    return all.firstWhere(
      (category) => category.id == id,
      orElse: () => all.first,
    );
  }
}
