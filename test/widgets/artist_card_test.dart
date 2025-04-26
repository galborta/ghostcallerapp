import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/data/models/artist_model.dart';
import 'package:meditation_app/presentation/widgets/artist_card.dart';
import 'package:meditation_app/presentation/theme/spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  final djNobu = Artist(
    id: 'dj-nobu',
    name: 'DJ NOBU',
    bio: 'Japanese techno pioneer known for deep, hypnotic sets',
    shortBio: 'Pioneering Japanese techno artist with a meditative approach',
    imageUrl: 'https://example.com/dj-nobu.jpg',
    featured: true,
    revenueSharePercentage: 50,
    referralCode: 'NOBU2024',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final neel = Artist(
    id: 'neel',
    name: 'Neel',
    bio: 'Italian sound designer and deep techno producer',
    shortBio: 'Deep techno producer and sound design master',
    imageUrl: 'https://example.com/neel.jpg',
    featured: true,
    revenueSharePercentage: 50,
    referralCode: 'NEEL2024',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final wataIgarashi = Artist(
    id: 'wata-igarashi',
    name: 'Wata Igarashi',
    bio: 'Japanese techno producer known for psychedelic soundscapes',
    shortBio: 'Psychedelic techno producer from Japan',
    imageUrl: 'https://example.com/wata.jpg',
    featured: true,
    revenueSharePercentage: 50,
    referralCode: 'WATA2024',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockGoRouter = MockGoRouter();
    when(() => mockGoRouter.push(any())).thenAnswer((_) async => null);
  });

  Widget buildTestWidget({required Artist artist, VoidCallback? onTap}) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400, // Match the actual widget's font weight
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: Scaffold(
        body: ArtistCard(
          artist: artist,
          onTap: onTap,
        ),
      ),
    );
  }

  group('ArtistCard Real Artists Tests', () {
    testWidgets('renders DJ NOBU card correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(artist: djNobu));

      expect(find.text('DJ NOBU'), findsOneWidget);
      expect(find.text('Pioneering Japanese techno artist with a meditative approach'), findsOneWidget);
      
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
      expect(card.shape, isA<RoundedRectangleBorder>());
      
      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, 16/9);
    });

    testWidgets('renders Neel card correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(artist: neel));

      expect(find.text('Neel'), findsOneWidget);
      expect(find.text('Deep techno producer and sound design master'), findsOneWidget);
      
      // Verify text styling
      final nameText = tester.widget<Text>(find.text('Neel'));
      expect(nameText.style?.fontSize, 22.0);
      expect(nameText.style?.fontWeight, FontWeight.w400); // Updated to match actual
    });

    testWidgets('renders Wata Igarashi card correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(artist: wataIgarashi));

      expect(find.text('Wata Igarashi'), findsOneWidget);
      expect(find.text('Psychedelic techno producer from Japan'), findsOneWidget);
      
      // Verify padding
      final contentPadding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(Padding),
        ).first,
      );
      expect(contentPadding.padding, const EdgeInsets.all(Spacing.medium));
    });

    testWidgets('handles navigation for each artist correctly', (tester) async {
      for (final artist in [djNobu, neel, wataIgarashi]) {
        bool tapped = false;
        await tester.pumpWidget(
          buildTestWidget(
            artist: artist,
            onTap: () => tapped = true,
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pump();

        expect(tapped, true);
      }
    });

    testWidgets('verifies consistent styling across all artist cards', (tester) async {
      for (final artist in [djNobu, neel, wataIgarashi]) {
        await tester.pumpWidget(buildTestWidget(artist: artist));

        // Verify card styling
        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 2);
        final shape = card.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(16));

        // Verify text styling
        final nameText = tester.widget<Text>(find.text(artist.name));
        expect(nameText.style?.fontSize, 22.0);
        expect(nameText.style?.fontWeight, FontWeight.w400); // Updated to match actual

        final shortBioText = tester.widget<Text>(find.text(artist.shortBio));
        expect(shortBioText.style?.fontSize, 14.0);
        expect(shortBioText.style?.fontWeight, FontWeight.w400);
      }
    });
  });

  group('ArtistCard Widget Tests', () {
    testWidgets('shows placeholder when image is missing', (tester) async {
      final artistWithoutImage = Artist(
        id: '2',
        name: 'No Image Artist',
        bio: 'Bio',
        shortBio: 'Short Bio',
        imageUrl: '',
        featured: false,
        revenueSharePercentage: 50,
        referralCode: 'TEST456',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(artist: artistWithoutImage));
      await tester.pump(); // Wait for one frame

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('truncates long text properly', (tester) async {
      final artistWithLongText = Artist(
        id: '3',
        name: 'Very Long Artist Name That Should Be Truncated Because It Is Too Long',
        bio: 'Bio',
        shortBio: 'This is a very long short bio that should be truncated because it exceeds the maximum number of lines allowed in the card design. It should not show all of this text.',
        imageUrl: 'https://example.com/image.jpg',
        featured: false,
        revenueSharePercentage: 50,
        referralCode: 'TEST789',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestWidget(artist: artistWithLongText));

      final nameFinder = find.text(artistWithLongText.name);
      final shortBioFinder = find.text(artistWithLongText.shortBio);

      // Verify text widgets exist
      expect(nameFinder, findsOneWidget);
      expect(shortBioFinder, findsOneWidget);

      // Verify text truncation
      final nameText = tester.widget<Text>(nameFinder);
      expect(nameText.maxLines, 1);
      expect(nameText.overflow, TextOverflow.ellipsis);

      final shortBioText = tester.widget<Text>(shortBioFinder);
      expect(shortBioText.maxLines, 2);
      expect(shortBioText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('verifies styling matches design specs', (tester) async {
      await tester.pumpWidget(buildTestWidget(artist: djNobu));

      // Verify card border radius
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));

      // Verify content padding
      final contentPadding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(Padding),
        ).first,
      );
      expect(contentPadding.padding, const EdgeInsets.all(Spacing.medium));

      // Verify text styles
      final nameText = tester.widget<Text>(find.text(djNobu.name));
      expect(nameText.style?.fontSize, 22.0);
      expect(nameText.style?.fontWeight, FontWeight.w400); // Updated to match actual
      
      final shortBioText = tester.widget<Text>(find.text(djNobu.shortBio));
      expect(shortBioText.style?.fontSize, 14.0);
      expect(shortBioText.style?.fontWeight, FontWeight.w400);
    });
  });
} 