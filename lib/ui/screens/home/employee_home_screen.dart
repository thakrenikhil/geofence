import 'package:flutter/material.dart';
import '../../../services/localization/app_localizations.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    return Scaffold(
      appBar: AppBar(title: Text(t('employee_home'))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _MapCard()),
                      const SizedBox(width: 16),
                      const Expanded(child: _ActionsCard()),
                    ],
                  )
                : Column(
                    children: [
                      const Expanded(child: _MapCard()),
                      const SizedBox(height: 16),
                      const _ActionsCard(),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: const Text('Map placeholder'),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: Text(t('check_in')),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: Text(t('check_out')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


