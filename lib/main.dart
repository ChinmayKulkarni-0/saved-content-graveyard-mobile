import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/analyze/presentation/analyze_screen.dart';

void main() {
  runApp(const GraveyardApp());
}

class GraveyardApp extends StatelessWidget {
  const GraveyardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saved Content Graveyard',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
      routes: {
        '/analyze': (context) => const AnalyzeScreen(),
      },
    );
  }
}