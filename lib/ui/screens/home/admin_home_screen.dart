import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.adminHome), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          },
        ),
      ]),
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
                _AdminTile(title: 'Offices', onTap: () => context.go('/admin/offices')),
                const _AdminTile(title: 'Employees'),
                const _AdminTile(title: 'Reports'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.title, this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
    );
  }
}


