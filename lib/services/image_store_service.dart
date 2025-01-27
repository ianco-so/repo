// import 'image_picker_service.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_database/firebase_database.dart';

class ImageStoreService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  // static final FirebaseDatabase _database = FirebaseDatabase.instance;

  static Future<String> storeImage(File fileImage) async {
    final ref = _storage.ref().child('photos').child(DateTime.now().millisecondsSinceEpoch.toString());
    final uploadTask = ref.putFile(fileImage);
    await uploadTask.whenComplete(() => null);
    String url = await ref.getDownloadURL();
    return url; // Return the URL of the uploaded image. This URL will be stored in the real-time database.
  }

}