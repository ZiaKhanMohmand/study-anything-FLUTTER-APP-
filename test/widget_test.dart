import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:study_anything/main.dart';
import 'package:study_anything/core/router/app_router.dart';

void main() {
  testWidgets('App builds with a router override', (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Study Anything Test Home')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(testRouter)],
        child: const StudyAnythingApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Study Anything Test Home'), findsOneWidget);
  });
}
