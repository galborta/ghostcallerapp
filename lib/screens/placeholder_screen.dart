import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/services/auth_service.dart';

class PlaceholderScreen extends ConsumerWidget {
  final String routeName;
  
  const PlaceholderScreen({
    super.key,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Placeholder for $routeName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'This screen is under construction',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (routeName == 'Profile') ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref.read(authServiceProvider.notifier).logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 