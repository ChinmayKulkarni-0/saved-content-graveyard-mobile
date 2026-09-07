import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/analysis_result.dart';
import 'result_card.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

enum AnalyzeState { idle, loading, complete, error }

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  AnalyzeState _state = AnalyzeState.idle;
  AnalysisResult? _result;
  String? _errorMessage;

  Future<void> _handleShareIntent() async {
    // TODO: Use share_handler to capture incoming screenshot
  }

  Future<void> _analyzeImage(String imagePath) async {
    setState(() => _state = AnalyzeState.loading);

    try {
      // TODO: Call ApiClient.analyzeScreenshot(imagePath)
      await Future.delayed(const Duration(seconds: 2));
      final mockResult = AnalysisResult(
        id: 'mock-1',
        description: 'Dr. Martens 1460 Pascal Virginia Boots',
        confidence: 0.92,
        category: 'product',
        tags: const ['boots', 'dr. martens', 'fashion'],
        processingTimeMs: 1200,
        productLinks: const [
          ProductLink(
            title: 'Dr. Martens 1460 Pascal Virginia Boots',
            price: '\$149.00',
            url: 'https://example.com/buy',
            source: 'Amazon',
            confidence: 0.95,
          ),
          ProductLink(
            title: 'Dr. Martens Official Store',
            price: '\$159.00',
            url: 'https://example.com/buy-2',
            source: 'Dr. Martens',
            confidence: 0.88,
          ),
        ],
      );
      setState(() {
        _result = mockResult;
        _state = AnalyzeState.complete;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to analyze image. Please try again.';
        _state = AnalyzeState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyze')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              switch (_state) {
                AnalyzeState.idle => const _IdleHint(),
                AnalyzeState.loading => const _LoadingView(),
                AnalyzeState.complete => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Processed in ${(_result!.processingTimeMs / 1000).toStringAsFixed(1)}s',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ResultCard(
                        result: _result!,
                        onSave: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved to library')),
                          );
                        },
                        onRetry: () => _analyzeImage('retry'),
                      ),
                    ],
                  ),
                AnalyzeState.error => _ErrorView(
                    message: _errorMessage ?? 'Something went wrong',
                    onRetry: () => _analyzeImage('retry'),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _IdleHint extends StatelessWidget {
  const _IdleHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.screenshot_rounded,
          size: 96,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withOpacity(0.4),
        ),
        const SizedBox(height: 24),
        Text(
          'Share a screenshot to get started',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the share button in any app and choose\n"Saved Content Graveyard"',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {
            // TODO: Trigger share intent handler
          },
          icon: const Icon(Icons.share),
          label: const Text('Take Screenshot'),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 96),
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Analyzing screenshot...',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Identifying product and streaming options',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.error_outline,
          size: 72,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ],
    );
  }
}
