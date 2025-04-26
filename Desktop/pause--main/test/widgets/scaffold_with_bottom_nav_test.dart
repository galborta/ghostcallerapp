import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/config/router.dart';
import 'package:meditation_app/presentation/widgets/scaffold_with_bottom_nav.dart';

void main() {
  group('ScaffoldWithBottomNav', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: RoutePath.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
            routes: [
              GoRoute(
                path: RoutePath.home,
                builder: (context, state) => const Placeholder(),
              ),
              GoRoute(
                path: RoutePath.calendar,
                builder: (context, state) => const Placeholder(),
              ),
              GoRoute(
                path: RoutePath.settings,
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
        ],
      );
    });

    testWidgets('renders bottom navigation bar with correct icons', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Verify all navigation destinations are present
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(3));

      // Verify icons
      expect(find.byIcon(Icons.home), findsOneWidget); // Selected home icon
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // Verify labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping tabs updates the active indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Initially home should be selected
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);

      // Tap calendar tab
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Calendar should be selected
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsNothing);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);

      // Tap settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Settings should be selected
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsNothing);
    });
  });
} 