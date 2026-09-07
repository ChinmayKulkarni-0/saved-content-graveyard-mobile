import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/api_client.dart';
import '../../../services/image_picker_service.dart';
import '../../../services/share_handler.dart';
import '../data/analysis_result.dart';
import '../data/mock_results.dart';
import 'result_card.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final imagePickerProvider =
    Provider<ImagePickerService>((ref) => ImagePickerService());

class AnalyzeScreen extends ConsumerStatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  ConsumerState<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

enum AnalyzeState { idle, loading, complete, error }

class _AnalyzeScreenState extends ConsumerState<AnalyzeScreen> {
  AnalyzeState _state = AnalyzeState.idle;
  AnalysisResult? _result;
  String? _errorMessage;
  File? _currentImage;

  @override
  void initState() {
    super.initState();
    _listenForShareIntent();
  }

  void _listenForShareIntent() {
    final shareHandler = ref.read(shareHandlerProvider);

    shareHandler.mediaStream.listen((file) async {
      final imageFile = await shareHandler.getFileFromMedia(file);
      if (imageFile != null && mounted) {
        _analyzeImage(imageFile);
      }
    });

    shareHandler.getInitialMedia().then((file) {
      if (file != null) {
        shareHandler.getFileFromMedia(file).then((imageFile) {
          if (imageFile != null && mounted) {
            _analyzeImage(imageFile);
          }
        });
      }
    });
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _state = AnalyzeState.loading;
      _currentImage = imageFile;
    });

    try {
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.path.split('/').last;
      final apiClient = ref.read(apiClientProvider);

      final result = await apiClient.analyzeScreenshot(
        imageBytes: bytes,
        filename: filename,
      );

      setState(() {
        _result = result;
        _state = AnalyzeState.complete;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _state = AnalyzeState.error;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to analyze image. Please try again.';
        _state = AnalyzeState.error;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ref.read(imagePickerProvider);
    final file = await picker.pickFromGallery();
    if (file != null) {
      _analyzeImage(file);
    }
  }

  Future<void> _takePhoto() async {
    final picker = ref.read(imagePickerProvider);
    final file = await picker.pickFromCamera();
    if (file != null) {
      _analyzeImage(file);
    }
  }

  void _retry() {
    if (_currentImage != null) {
      _analyzeImage(_currentImage!);
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
                AnalyzeState.idle => _IdleHint(
                    onPickGallery: _pickFromGallery,
                    onTakePhoto: _takePhoto,
                  ),
                AnalyzeState.loading => const _LoadingView(),
                AnalyzeState.complete => Column(
                    children: [
                      if (_currentImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _currentImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ResultCard(
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
                        onRetry: _retry,
                      ),
                    ],
                  ),
                AnalyzeState.error => _ErrorView(
                    message: _errorMessage ?? 'Something went wrong',
                    onRetry: _retry,
                    onPickGallery: _pickFromGallery,
                    onTakePhoto: _takePhoto,
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
  final VoidCallback onPickGallery;
  final VoidCallback onTakePhoto;

  const _IdleHint({
    required this.onPickGallery,
    required this.onTakePhoto,
  });

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: onTakePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onPickGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
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
  final VoidCallback onPickGallery;
  final VoidCallback onTakePhoto;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onPickGallery,
    required this.onTakePhoto,
  });

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onPickGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),
      ],
    );
  }
}
