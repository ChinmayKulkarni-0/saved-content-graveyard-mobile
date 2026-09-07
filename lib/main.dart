import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/share_handler.dart';

final shareHandlerProvider = Provider<ShareHandler>((ref) {
  final handler = ShareHandler();
  handler.init();
  ref.onDispose(() => handler.dispose());
  return handler;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GraveyardApp(),
    ),
  );
}

class GraveyardApp extends ConsumerWidget {
  const GraveyardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Saved Content Graveyard',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
