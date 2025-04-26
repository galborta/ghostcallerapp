import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/app/core/constants/spacing.dart';
import 'package:meditation_app/services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show admin section to all authenticated users for now
    final isAdmin = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.large),
        children: [
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
              title: const Text('Upload Tracks'),
              subtitle: const Text('Add new meditation tracks'),
              onTap: () => context.push('/settings/admin/upload'),
            ),
          ],

          const Divider(),

          // Account Actions
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authServiceProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
} 