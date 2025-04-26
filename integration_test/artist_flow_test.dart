import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pause/main.dart' as app;
import 'package:pause/models/artist.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Artist Browsing Flow Tests', () {
    testWidgets('Complete happy path - browse, search and view artist',
        (tester) async {
      await mockNetworkImagesFor(() async {
        app.main();
        await tester.pumpAndSettle();

        // Verify initial state
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(ListTile), findsWidgets);

        // Test search functionality
        await tester.enterText(find.byType(TextField), 'test artist');
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.byType(ListTile), findsWidgets);
        expect(find.text('test artist'), findsOneWidget);

        // Tap on an artist
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();

        // Verify artist details page
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Image), findsWidgets);
        expect(find.byType(Text), findsWidgets);
      });
    });

    testWidgets('Search with no results shows empty state', (tester) async {
      await mockNetworkImagesFor(() async {
        app.main();
        await tester.pumpAndSettle();

        // Enter search query that should yield no results
        await tester.enterText(find.byType(TextField), 'nonexistent artist xyz');
        await tester.pumpAndSettle();

        // Verify empty state
        expect(find.text('No artists found'), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
      });
    });

    testWidgets('Network error shows error state', (tester) async {
      await mockNetworkImagesFor(() async {
        // TODO: Mock network error here
        app.main();
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget); // Retry button
      });
    });

    testWidgets('UI elements are correctly positioned across screen sizes',
        (tester) async {
      await mockNetworkImagesFor(() async {
        app.main();

        // Test different screen sizes
        const sizes = [
          Size(320, 480), // Small phone
          Size(375, 812), // iPhone X
          Size(768, 1024), // Tablet
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);
          await tester.pumpAndSettle();

          // Verify no overflow errors
          expect(tester.takeException(), isNull);

          // Verify key elements are visible
          expect(find.byType(TextField), findsOneWidget);
          expect(find.byType(BottomNavigationBar), findsOneWidget);
        }
      });
    });
  });

  group('Design Verification Tests', () {
    testWidgets('UI matches design specifications', (tester) async {
      await mockNetworkImagesFor(() async {
        app.main();
        await tester.pumpAndSettle();

        // Verify search bar
        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);
        expect(find.text('Search artists...'), findsOneWidget);

        // Verify artist list item styling
        final listItem = find.byType(ListTile).first;
        final listItemWidget = tester.widget<ListTile>(listItem);
        
        // Verify padding
        expect(
          tester.getRect(listItem).height,
          greaterThanOrEqualTo(72.0), // Material Design minimum touch target
        );

        // Verify typography
        final titleStyle = listItemWidget.title?.runtimeType;
        expect(titleStyle, Text);
        
        // Verify buttons and interactive elements
        expect(find.byType(InkWell), findsWidgets);
      });
    });
  });
} 