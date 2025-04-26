import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/main.dart';
import 'package:meditation_app/services/auth_service.dart';

class TestAuthService extends AuthService {
  @override
  Future<void> login() async {
    state = true;
  }

  @override
  Future<void> logout() async {
    state = false;
  }
}

void main() {
  late TestAuthService testAuthService;
  late ProviderContainer container;

  setUp(() {
    testAuthService = TestAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWith((ref) => testAuthService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Widget createApp() {
    return UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    );
  }

  group('Bottom Navigation Tests', () {
    testWidgets('Bottom navigation bar switches screens correctly',
        (WidgetTester tester) async {
      await testAuthService.login();
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Verify we start on the home screen
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
      
      // Navigate to Meditate tab
      await tester.tap(find.byIcon(Icons.self_improvement));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Meditate'), findsOneWidget);
      
      // Navigate to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
      
      // Navigate back to Home tab
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    });

    testWidgets('GoRouter state updates with bottom navigation',
        (WidgetTester tester) async {
      await testAuthService.login();
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final router = container.read(routerProvider);
      
      // Start at home
      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
      
      // Navigate to Meditate
      await tester.tap(find.byIcon(Icons.self_improvement));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/meditate');
      
      // Navigate to Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');
    });
  });

  group('Authentication Navigation Tests', () {
    testWidgets('Unauthenticated users are redirected to login',
        (WidgetTester tester) async {
      await testAuthService.logout();
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
      
      // Try to navigate to a protected route
      final router = container.read(routerProvider);
      router.go('/profile');
      await tester.pumpAndSettle();
      
      // Verify we're still on login
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    });

    testWidgets('Authenticated users can access protected routes',
        (WidgetTester tester) async {
      await testAuthService.login();
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Verify we can access protected route
      final router = container.read(routerProvider);
      router.go('/profile');
      await tester.pumpAndSettle();
      
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    });

    testWidgets('Logout redirects to login screen', (WidgetTester tester) async {
      await testAuthService.login();
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // Trigger logout
      await testAuthService.logout();
      await tester.pump();
      await tester.pumpAndSettle();
      
      // Verify we're redirected to login
      expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    });
  });

  group('Screen Transition Tests', () {
    testWidgets('Screen transitions update route correctly',
        (WidgetTester tester) async {
      await testAuthService.login();
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      final router = container.read(routerProvider);
      
      // Initial route
      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

      // Start transition to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();
      
      // Mid-transition
      await tester.pump(const Duration(milliseconds: 100));
      
      // End transition
      await tester.pumpAndSettle();
      
      // Verify final state
      expect(router.routerDelegate.currentConfiguration.uri.path, '/profile');
      expect(find.widgetWithText(AppBar, 'Profile'), findsOneWidget);
    });
  });
} 