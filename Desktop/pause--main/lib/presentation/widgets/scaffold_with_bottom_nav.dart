import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/config/router.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(RoutePath.home)) return 0;
    if (location.startsWith(RoutePath.calendar)) return 1;
    if (location.startsWith(RoutePath.settings)) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RoutePath.home);
        break;
      case 1:
        context.go(RoutePath.calendar);
        break;
      case 2:
        context.go(RoutePath.settings);
        break;
    }
  }
} 