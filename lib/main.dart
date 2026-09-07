import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/analyze/presentation/analyze_screen.dart';
import 'services/share_handler.dart';

final shareHandlerProvider = Provider<ShareHandler>((ref) {
  final handler = ShareHandler();
  handler.init();
  ref.onDispose(() => handler.dispose());
  return handler;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: GraveyardApp()));
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
