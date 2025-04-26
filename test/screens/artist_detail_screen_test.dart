import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/presentation/screens/artist_detail_screen.dart';
import 'package:meditation_app/presentation/theme/spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.push(any())).thenAnswer((_) async => null);
  });

  Widget buildTestWidget({required String artistId}) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
          ),
        ),
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: ArtistDetailScreen(artistId: artistId),
        ),
      ),
    );
  }

  group('ArtistDetailScreen Tests', () {
    testWidgets('renders all screen elements correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
        await tester.pump();

        // Verify app bar and image
        expect(find.byType(SliverAppBar), findsOneWidget);
        expect(find.byType(FlexibleSpaceBar), findsOneWidget);
        expect(find.text('Artist Name'), findsOneWidget);

        // Verify content sections
        expect(find.text('Short bio'), findsOneWidget);
        expect(find.text('Biography'), findsOneWidget);
        expect(find.text('Full biography'), findsOneWidget);
        expect(find.text('Meditation Tracks'), findsOneWidget);

        // Verify FAB
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Start Meditation'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });
    });

    testWidgets('handles responsive layout on different screen sizes', (tester) async {
      await mockNetworkImagesFor(() async {
        // Test on phone size
        tester.binding.window.physicalSizeTestValue = const Size(375 * 3, 812 * 3);
        tester.binding.window.devicePixelRatioTestValue = 3.0;
        
        await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
        await tester.pump();

        final phoneAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
        expect(phoneAppBar.expandedHeight, 300);

        // Test on tablet size
        tester.binding.window.physicalSizeTestValue = const Size(834 * 2, 1194 * 2);
        tester.binding.window.devicePixelRatioTestValue = 2.0;
        
        await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
        await tester.pump();

        // Verify content is still visible and properly laid out
        expect(find.text('Artist Name'), findsOneWidget);
        expect(find.text('Biography'), findsOneWidget);
        expect(find.text('Meditation Tracks'), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    testWidgets('navigates to session setup when Start Meditation is tapped',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
        await tester.pump();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        verify(() => mockGoRouter.push('/session-setup/test-id')).called(1);
      });
    });

    testWidgets('verifies styling and layout according to design', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
        await tester.pump();

        // Verify app bar styling
        final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
        expect(appBar.pinned, true);
        expect(appBar.expandedHeight, 300);

        // Verify text styling
        final titleText = tester.widget<Text>(find.text('Biography'));
        final titleStyle = titleText.style as TextStyle;
        expect(titleStyle.fontSize, 22.0);
        expect(titleStyle.fontWeight, FontWeight.w400);

        // Verify content padding
        final paddingFinder = find.byType(SliverPadding);
        expect(paddingFinder, findsOneWidget);
        final padding = tester.widget<SliverPadding>(paddingFinder).padding;
        expect(padding, const EdgeInsets.all(Spacing.medium));

        // Verify spacing between sections
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final spacingHeights = sizedBoxes
            .map((box) => box.height)
            .whereType<double>()
            .toList();

        // Verify we have the correct spacing values
        expect(spacingHeights, containsAll([
          Spacing.medium, // After short bio
          Spacing.small,  // After Biography heading
          Spacing.large,  // After bio text
          Spacing.small,  // After Meditation Tracks heading
          80.0,          // Bottom padding for FAB
        ]));
      });
    });

    testWidgets('shows loading state for image', (tester) async {
      await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles scroll behavior correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestWidget(artistId: 'test-id'));
        await tester.pump();

        // Find the scroll view
        final scrollView = find.byType(CustomScrollView);
        expect(scrollView, findsOneWidget);

        // Scroll down
        await tester.drag(scrollView, const Offset(0, -500));
        await tester.pump();

        // Verify app bar is still visible (pinned)
        expect(find.byType(SliverAppBar), findsOneWidget);

        // Verify FAB is still visible after scrolling
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });
  });
} 