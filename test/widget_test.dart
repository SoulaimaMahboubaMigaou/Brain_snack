import 'package:flutter_test/flutter_test.dart';

import 'package:brainsnack/auth/auth_service.dart';
import 'package:brainsnack/main.dart';
import 'package:brainsnack/services/leaderboard_service.dart';
import 'package:brainsnack/services/mock_quiz_api_service.dart';
import 'package:brainsnack/services/result_service.dart';

void main() {
  testWidgets('BrainSnack login screen renders', (tester) async {
    await tester.pumpWidget(
      BrainSnackApp(
        authService: AuthService(),
        resultService: ResultService(),
        leaderboardService: LeaderboardService(),
        quizApiService: MockQuizApiService(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('BrainSnack'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Need an account? Register'), findsOneWidget);
  });
}
