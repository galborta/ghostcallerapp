import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditation_app/data/models/track_model.dart';
import 'package:meditation_app/presentation/screens/meditation/meditation_player_screen.dart';
import 'package:meditation_app/presentation/state/meditation_provider.dart';
import 'package:meditation_app/core/theme/typography.dart';

// Mock track for testing
final mockTrack = Track(
  id: '1',
  title: 'Test Meditation',
  description: 'Test Description',
  duration: 600,
  audioUrl: 'https://example.com/audio.mp3',
  artistId: '1',
  isGuided: true,
  category: 'meditation',
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        currentTrackProvider.overrideWithValue(mockTrack),
        meditationStateProvider.overrideWithValue(MeditationState.initial),
        remainingTimeProvider.overrideWithValue(const Duration(minutes: 10)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MeditationPlayerScreen UI Elements', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      // Verify track info is displayed
      expect(find.text('Test Meditation'), findsOneWidget);
      expect(find.text('Guided Meditation'), findsOneWidget);

      // Verify timer is displayed
      expect(find.text('10:00'), findsOneWidget);

      // Verify volume control exists
      expect(find.text('Volume'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byIcon(Icons.volume_down), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Verify play button exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows correct meditation type text', (tester) async {
      // Test guided meditation
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );
      expect(find.text('Guided Meditation'), findsOneWidget);

      // Test music only
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: false,
              durationMinutes: 10,
            ),
          ),
        ),
      );
      expect(find.text('Music Only'), findsOneWidget);
    });
  });

  group('Playback Controls', () {
    testWidgets('play/pause button toggles correctly', (tester) async {
      // Override with initial state
      final container = ProviderContainer(
        overrides: [
          currentTrackProvider.overrideWithValue(mockTrack),
          meditationStateProvider.overrideWithValue(MeditationState.initial),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      // Initial state should show play button
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);

      // Override with playing state
      container.updateOverrides([
        meditationStateProvider.overrideWithValue(MeditationState.inProgress),
      ]);
      await tester.pump();

      // Should now show pause button
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('volume slider updates correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      // Test slider value update
      await tester.tap(slider);
      await tester.pump();
      
      // Verify slider moved
      final Slider sliderWidget = tester.widget(slider);
      expect(sliderWidget.value, isNot(equals(0.0)));
    });
  });

  group('Timer Updates', () {
    testWidgets('countdown timer updates correctly', (tester) async {
      // Start with 10 minutes
      container.updateOverrides([
        remainingTimeProvider.overrideWithValue(const Duration(minutes: 10)),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      expect(find.text('10:00'), findsOneWidget);

      // Update to 9 minutes 30 seconds
      container.updateOverrides([
        remainingTimeProvider.overrideWithValue(const Duration(minutes: 9, seconds: 30)),
      ]);
      await tester.pump();

      expect(find.text('09:30'), findsOneWidget);
    });
  });

  group('Navigation and Dialog', () {
    testWidgets('shows confirmation dialog on back button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('End Meditation?'), findsOneWidget);
      expect(find.text('Are you sure you want to end your meditation session?'), findsOneWidget);
      expect(find.text('Continue Meditating'), findsOneWidget);
      expect(find.text('End Session'), findsOneWidget);
    });

    testWidgets('continues session when dialog is dismissed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Tap continue
      await tester.tap(find.text('Continue Meditating'));
      await tester.pumpAndSettle();

      // Verify we're still on the meditation screen
      expect(find.byType(MeditationPlayerScreen), findsOneWidget);
    });
  });

  group('Styling', () {
    testWidgets('applies correct typography styles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      // Verify timer uses headline1 style with custom size
      final timerText = tester.widget<Text>(
        find.text('10:00'),
      );
      expect(
        timerText.style?.fontSize,
        equals(72),
      );

      // Verify track title uses headline2 style
      final titleText = tester.widget<Text>(
        find.text('Test Meditation'),
      );
      expect(
        titleText.style,
        equals(AppTypography.headline2),
      );
    });

    testWidgets('applies correct spacing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: MeditationPlayerScreen(
              trackId: '1',
              isGuidedMeditation: true,
              durationMinutes: 10,
            ),
          ),
        ),
      );

      // Verify padding around volume control
      final volumeCard = tester.widget<Padding>(
        find.ancestor(
          of: find.text('Volume'),
          matching: find.byType(Padding),
        ),
      );
      expect(volumeCard.padding, isA<EdgeInsets>());
    });
  });
} 