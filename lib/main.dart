import 'package:brainsnack/auth/auth_service.dart';
import 'package:brainsnack/providers/auth_provider.dart';
import 'package:brainsnack/providers/home_provider.dart';
import 'package:brainsnack/providers/leaderboard_provider.dart';
import 'package:brainsnack/providers/quiz_provider.dart';
import 'package:brainsnack/screens/home_screen.dart';
import 'package:brainsnack/screens/leaderboard_screen.dart';
import 'package:brainsnack/screens/login_screen.dart';
import 'package:brainsnack/screens/quiz_screen.dart';
import 'package:brainsnack/screens/register_screen.dart';
import 'package:brainsnack/screens/result_screen.dart';
import 'package:brainsnack/services/leaderboard_service.dart';
import 'package:brainsnack/services/mock_quiz_api_service.dart';
import 'package:brainsnack/services/result_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  final resultService = ResultService();
  final leaderboardService = LeaderboardService();
  final quizApiService = MockQuizApiService();

  runApp(
    BrainSnackApp(
      authService: authService,
      resultService: resultService,
      leaderboardService: leaderboardService,
      quizApiService: quizApiService,
    ),
  );
}

class BrainSnackApp extends StatelessWidget {
  const BrainSnackApp({
    super.key,
    required this.authService,
    required this.resultService,
    required this.leaderboardService,
    required this.quizApiService,
  });

  final AuthService authService;
  final ResultService resultService;
  final LeaderboardService leaderboardService;
  final MockQuizApiService quizApiService;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Segoe UI',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1FC8A5),
        brightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<ResultService>.value(value: resultService),
        Provider<LeaderboardService>.value(value: leaderboardService),
        Provider<MockQuizApiService>.value(value: quizApiService),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService)..restoreSession(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (context) => HomeProvider(
            resultService: resultService,
            authProvider: context.read<AuthProvider>(),
          ),
          update: (_, authProvider, homeProvider) =>
              homeProvider!..attachAuth(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, QuizProvider>(
          create: (context) => QuizProvider(
            apiService: quizApiService,
            resultService: resultService,
            authProvider: context.read<AuthProvider>(),
          ),
          update: (_, authProvider, quizProvider) =>
              quizProvider!..attachAuth(authProvider),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LeaderboardProvider>(
          create: (context) => LeaderboardProvider(
            leaderboardService: leaderboardService,
            authProvider: context.read<AuthProvider>(),
          )..refresh(),
          update: (_, authProvider, leaderboardProvider) =>
              leaderboardProvider!..attachAuth(authProvider),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BrainSnack',
        theme: baseTheme.copyWith(
          scaffoldBackgroundColor: const Color(0xFF06111D),
          cardTheme: const CardThemeData(
            color: Color(0xFF122033),
            elevation: 0,
            margin: EdgeInsets.zero,
          ),
          textTheme: baseTheme.textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF1FC8A5)),
            ),
          ),
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          LeaderboardScreen.routeName: (_) => const LeaderboardScreen(),
          QuizScreen.routeName: (_) => const QuizScreen(),
          ResultScreen.routeName: (_) => const ResultScreen(),
        },
      ),
    );
  }
}
