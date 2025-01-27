import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final _picker = ImagePicker();

  static Future<File> pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) throw Exception('Imagem não selecionada.');
    return File(pickedFile.path);
  }

  static Future<File> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) throw Exception('Imagem não selecionada.');
    return File(pickedFile.path);
  }
}
