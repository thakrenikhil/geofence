import 'package:flutter/material.dart';
import '../../../flutter_gen/gen_l10n/app_localizations.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.adminHome)),
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
              children: const [
                _AdminTile(title: 'Offices'),
                _AdminTile(title: 'Employees'),
                _AdminTile(title: 'Reports'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}


