import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Reusable function to pick an image from gallery or camera.
///
/// [fromCamera] - If true, opens the camera. If false, opens the gallery.
/// Returns a `File` of the selected image, or null if no image was picked.
Future<File?> pickImage({bool fromCamera = false}) async {
  final picker = ImagePicker();

  final XFile? pickedFile = await picker.pickImage(
    source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    imageQuality: 80, // Optional: compress image to reduce file size
  );

  if (pickedFile != null) {
    return File(pickedFile.path);
  } else {
    print('❌ No image selected');
    return null;
  }
}
