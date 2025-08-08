import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({super.key, required this.title, required this.body, this.actions});

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 12, vertical: 12),
        child: body,
      ),
    );
  }
}


