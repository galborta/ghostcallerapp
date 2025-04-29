import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.isAdmin ?? false;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.large),
        children: [
          // Upload Section at the top for better visibility
          if (isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.upload, size: 32),
              title: const Text('Upload Artist & Track', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: const Text('Add new meditation content'),
              tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
              ),
              contentPadding: const EdgeInsets.all(16),
              onTap: () => context.push('/settings/admin/upload'),
            ),
            const SizedBox(height: Spacing.large),
            const Divider(),
          ],

          // Account Section
          const Text('Account', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: Spacing.medium),
          
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              // TODO: Navigate to profile settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),

          const Divider(),

          // App Settings Section
          const Text('App Settings', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: Spacing.medium),
          
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                // TODO: Implement theme switching
              },
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text('Sound Settings'),
            onTap: () {
              // TODO: Navigate to sound settings
            },
          ),

          if (isAdmin) ...[
            const Divider(),

            // Admin Section
            const Text('Admin', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: Spacing.medium),
            
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Upload Artist & Track'),
              subtitle: const Text('Add new meditation content'),
              onTap: () => context.push('/settings/admin/upload'),
            ),
          ],

          const Divider(),

          // Account Actions
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              try {
                await ref.read(authRepositoryProvider).signOut();
                // Invalidate auth state to trigger router redirect
                ref.invalidate(isAuthenticatedProvider);
                ref.invalidate(currentUserProvider);
                
                if (context.mounted) {
                  // Navigate to login screen
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to logout. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
} 