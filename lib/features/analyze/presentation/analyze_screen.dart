import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/api_client.dart';
import '../../../services/image_picker_service.dart';
import '../../../services/share_handler.dart';
import '../../home/home_screen.dart';
import '../data/analysis_result.dart';
import 'result_card.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final imagePickerProvider = Provider<ImagePickerService>((ref) => ImagePickerService());

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
                          'Processed in ${_result?.processingTimeMs.toStringAsFixed(0) ?? '0'}ms',
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
        Icon(
          Icons.screenshot_rounded,
          size: 96,
          color: AppColors.textSecondary.withOpacity(0.4),
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 96),
        CircularProgressIndicator(),
        SizedBox(height: 24),
        Text('Analyzing screenshot...'),
        SizedBox(height: 8),
        Text(
          'Identifying product and streaming options',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

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
        const Icon(Icons.error_outline, size: 72, color: AppColors.error),
        const SizedBox(height: 24),
        Text(message, textAlign: TextAlign.center),
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
