import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit app?'),
            content: const Text('Do you want to close the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.adminHome),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                // Note: Admins don't have active attendance records,
                // but we keep the same sign-out pattern for consistency
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Signed out')));
                  context.go('/login');
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final gridCount = isWide ? 3 : 1;
              return GridView.count(
                crossAxisCount: gridCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _AdminTile(
                    title: 'Offices',
                    icon: Icons.location_pin,
                    color: Colors.indigo,
                    onTap: () => context.push('/admin/offices'),
                  ),
                  _AdminTile(
                    title: 'Employees',
                    icon: Icons.group_add,
                    color: Colors.teal,
                    onTap: () => context.push('/admin/employees'),
                  ),
                  const _AdminTile(
                    title: 'Reports',
                    icon: Icons.description,
                    color: Colors.orange,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.title, this.onTap, this.icon, this.color});
  final String title;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(
          0.1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    (color ?? Theme.of(context).colorScheme.primary)
                        .withOpacity(0.15),
                child: Icon(
                  icon ?? Icons.dashboard,
                  color: color ?? Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
