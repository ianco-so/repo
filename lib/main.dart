import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadImageScreen(),
    );
  }
}

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  bool _isUploading = false;
  String? _uploadedImageUrl;

  Future<void> _captureAndUploadImage() async {
    try {
      // Captura a imagem usando a câmera
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;

      File imageFile = File(pickedFile.path);

      setState(() {
        _isUploading = true;
      });

      // Upload para o Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('images/$fileName');
      await storageRef.putFile(imageFile);

      // Obter URL da imagem
      String imageUrl = await storageRef.getDownloadURL();

      // Salvar URL no Firebase Realtime Database
      DatabaseReference dbRef = _database.ref().child('images');
      await dbRef.push().set({'url': imageUrl});

      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagem enviada com sucesso!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar imagem: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste Firebase Storage'),
      ),
      body: Center(
        child: _isUploading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _captureAndUploadImage,
                    child: Text('Tirar Foto e Enviar'),
                  ),
                  if (_uploadedImageUrl != null) ...[
                    SizedBox(height: 20),
                    Text('Imagem Enviada:', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Image.network(_uploadedImageUrl!, height: 200),
                  ],
                ],
              ),
      ),
    );
  }
}
