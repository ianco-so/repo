import 'package:flutter/material.dart';
import 'package:repo/services/image_store_service.dart';
import '../models/contact.dart';
import '../models/location.dart';
import '../models/status.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/image_picker_service.dart';

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _photoUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Contato')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira um nome.' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Sobrenome'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              Row(
                children: [
                  ElevatedButton(
                    child: Text('Tirar Foto'),
                    onPressed: () async {
                      final file = await ImagePickerService.pickImageFromCamera();
                      final url = await ImageStoreService.storeImage(file);
                      setState(() => _photoUrl = url);
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    child: Text('Selecionar da Galeria'),
                    onPressed: () async {
                      final file = await ImagePickerService.pickImageFromGallery();
                      final url = await ImageStoreService.storeImage(file);
                      setState(() => _photoUrl = url);
                    },
                  ),
                ],
              ),
              if (_photoUrl.isNotEmpty)
                Image.network(_photoUrl, height: 100, width: 100),
              ElevatedButton(
                child: Text('Salvar'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final contact = Contact(
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      phone: _phoneController.text,
                      email: _emailController.text,
                      status: Status.NORMAL,
                      photoUrl: _photoUrl,
                      location: Location(latitude: 0, longitude: 0),
                    );

                    try {
                      // Referência ao Firebase Realtime Database
                      DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('contacts');
                      await dbRef.push().set({
                        'firstName': contact.firstName,
                        'lastName': contact.lastName,
                        'phone': contact.phone,
                        'email': contact.email,
                        'status': contact.status.name,
                        'photoUrl': contact.photoUrl,
                        'location': {
                          'latitude': contact.location.latitude,
                          'longitude': contact.location.longitude,
                        },
                      });

                      // Exibe uma mensagem de sucesso
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Contato salvo com sucesso!')),
                      );

                      Navigator.of(context).pop(); // Retorna para a tela anterior
                    } catch (e) {
                      // Trata erros
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar contato: $e')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
