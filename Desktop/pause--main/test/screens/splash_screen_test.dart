import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/presentation/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders logo correctly', (tester) async {
      // Build the splash screen
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify logo is present
      expect(find.byKey(const Key('splash_logo')), findsOneWidget);
      
      // Verify logo text and styling
      final logoText = tester.widget<Text>(
        find.byKey(const Key('splash_logo')),
      );
      expect(logoText.data, 'O');
      expect(logoText.style?.fontFamily, 'Mourier');
      expect(logoText.style?.fontSize, 120);
      
      // Verify logo container is sized correctly
      final logoBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const Key('splash_logo')),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(logoBox.width, 160);
      expect(logoBox.height, 160);
    });

    testWidgets('starts animation correctly', (tester) async {
      // Build the splash screen
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Get initial opacity
      final initialOpacity = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      ).opacity.value;
      expect(initialOpacity, 0.0);

      // Wait for half the animation duration
      await tester.pump(const Duration(milliseconds: 750));

      // Get mid-animation opacity
      final midOpacity = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      ).opacity.value;
      expect(midOpacity, greaterThan(0.0));
      expect(midOpacity, lessThan(1.0));

      // Wait for full animation duration
      await tester.pump(const Duration(milliseconds: 750));

      // Get final opacity
      final finalOpacity = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      ).opacity.value;
      expect(finalOpacity, 1.0);
    });

    testWidgets('shows loading animation', (tester) async {
      // Build the splash screen
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify loading animation is present
      expect(find.byKey(const Key('splash_loading_animation')), findsOneWidget);
      
      // Verify loading animation is sized correctly
      final loadingBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const Key('splash_loading_animation')),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(loadingBox.width, 60);
      expect(loadingBox.height, 60);
    });
  });
} 