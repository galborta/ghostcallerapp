import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/config/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Router Configuration Tests', () {
    test('router provider creates GoRouter instance', () {
      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });

    test('route paths are correctly defined', () {
      expect(RoutePath.splash, equals('/'));
      expect(RoutePath.login, equals('/login'));
      expect(RoutePath.register, equals('/register'));
      expect(RoutePath.forgotPassword, equals('/forgot-password'));
      expect(RoutePath.home, equals('/home'));
      expect(RoutePath.artistDetail, equals('/artist/:id'));
      expect(RoutePath.meditationPlayer, equals('/meditation/:id'));
      expect(RoutePath.calendar, equals('/calendar'));
      expect(RoutePath.settings, equals('/settings'));
    });

    test('route names are correctly defined', () {
      expect(RouteName.splash, equals('splash'));
      expect(RouteName.login, equals('login'));
      expect(RouteName.register, equals('register'));
      expect(RouteName.forgotPassword, equals('forgotPassword'));
      expect(RouteName.home, equals('home'));
      expect(RouteName.artistDetail, equals('artistDetail'));
      expect(RouteName.meditationPlayer, equals('meditationPlayer'));
      expect(RouteName.calendar, equals('calendar'));
      expect(RouteName.settings, equals('settings'));
    });
  });
} 