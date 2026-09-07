import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareHandler {
  StreamSubscription<SharedMediaFile>? _subscription;
  final _controller = StreamController<SharedMediaFile>.broadcast();
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _subscription = ReceiveSharingIntent.getMediaStream().listen(
      (SharedMediaFile file) {
        _controller.add(file);
      },
      onError: (err) {
        _controller.addError(err);
      },
    );
  }

  Future<SharedMediaFile?> getInitialMedia() async {
    try {
      final files = await ReceiveSharingIntent.getInitialMedia();
      if (files.isNotEmpty) {
        return files.first;
      }
    } catch (_) {}
    return null;
  }

  Stream<SharedMediaFile> get mediaStream => _controller.stream;

  bool isImageFile(SharedMediaFile file) {
    final path = file.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.heic');
  }

  Future<File?> getFileFromMedia(SharedMediaFile file) async {
    if (!isImageFile(file)) return null;
    final f = File(file.path);
    if (await f.exists()) return f;
    return null;
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
