import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/home_screen.dart';
import '../data/analysis_result.dart';
import '../data/mock_results.dart';
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
      // Rotate through mock results for demo purposes
      final mocks = [MockResults.product, MockResults.movie, MockResults.mixed];
      final idx = _result == null
          ? 0
          : (mocks.indexWhere((m) => m.id == _result!.id) + 1) % mocks.length;
      setState(() {
        _result = mocks[idx];
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
      appBar: AppBar(
        title: const Text('Analyze'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              switch (_state) {
                AnalyzeState.idle => _IdleHint(onAnalyze: _analyzeImage),
                AnalyzeState.loading => const _LoadingView(),
                AnalyzeState.complete => ResultCard(
                    key: ValueKey(_result!.id),
                    result: _result!,
                    onSave: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Saved to library'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    onRetry: () => _analyzeImage('retry'),
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

// ─── Idle hint ──────────────────────────────────────────────────────────────

class _IdleHint extends StatelessWidget {
  final Function(String) onAnalyze;
  const _IdleHint({required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.screenshot_rounded,
            size: 48,
            color: AppColors.primary.withOpacity(0.3),
          ),
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
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () => onAnalyze('demo'),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Try with mock data'),
        ),
        const SizedBox(height: 12),
        Text(
          'Tap to see the Result Card in action',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Loading view ───────────────────────────────────────────────────────────

class _LoadingView extends StatefulWidget {
  const _LoadingView();

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 64),
        FadeTransition(
          opacity: _pulse,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Analyzing your screenshot...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Identifying content and finding the best links',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// ─── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Oops, something went wrong',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ],
    );
  }
}
