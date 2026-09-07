import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromGallery() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  Future<File?> pickFromCamera() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  Future<File?> pickImage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }
}
