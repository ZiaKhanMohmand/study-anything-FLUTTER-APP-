import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:study_anything/core/models/question_model.dart';
import 'package:study_anything/features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/upload/screens/upload_screen.dart';
import '../../features/quiz/screens/mode_select_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/results/screens/results_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/upload',
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/mode-select',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ModeSelectScreen(
            pdfText: extra['pdfText'] as String,
            pdfName: extra['pdfName'] as String,
          );
        },
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizScreen(
            questions: List<Question>.from(extra['questions']),
            pdfName: extra['pdfName'] as String,
            pdfText: extra['pdfText'] as String, // ADD THIS
          );
        },
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResultsScreen(result: extra['result']);
        },
      ),
    ],
    redirect: (context, state) {
      final box = Hive.box('settings');
      final done = box.get('onboarding_done', defaultValue: false) as bool;
      if (!done && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
  );
});
