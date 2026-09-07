import 'dart:async';
import 'dart:io';

class ShareHandler {
  Future<File?> getPendingScreenshot() async {
    // TODO: Use share_handler package to receive shared images
    // 1. Register share intent
    // 2. Listen for incoming shared files
    // 3. Return the first image file received
    return null;
  }

  Future<void> clearPendingScreenshot() async {
    // TODO: Clear the handled share payload
  }

  Stream<File> get sharedFileStream() {
    // TODO: Implement stream of incoming shared files
    return const Stream.empty();
  }
}