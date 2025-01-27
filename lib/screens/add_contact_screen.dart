import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/contact.dart';
import '../models/location.dart';
import '../models/status.dart';
import '../services/image_picker_service.dart';
import '../services/image_store_service.dart';
import '../utils/location_util.dart';
import '../screens/map_screen.dart';

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
  LatLng? _selectedLocation;
  String? _staticMapUrl;

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _staticMapUrl = LocationUtil.generateLocationPreviewImage(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    });
  }

  Future<void> _selectOnMap() async {
    final LatLng? selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(),
      ),
    );

    if (selectedPosition != null) {
      _selectLocation(selectedPosition);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos e selecione um local!')),
      );
      return;
    }

    final contact = Contact(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      status: Status.NORMAL,
      photoUrl: _photoUrl,
      location: Location(
        latitude: _selectedLocation!.latitude.toString(),
        longitude: _selectedLocation!.longitude.toString(),
      ),
    );

    try {
      final dbRef = FirebaseDatabase.instance.ref().child('contacts');
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato salvo com sucesso!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar contato: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Contato')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Por favor, insira um nome.' : null,
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
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.map),
                label: Text('Selecione no Mapa'),
                onPressed: _selectOnMap,
              ),
              if (_staticMapUrl != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
                  child: Image.network(_staticMapUrl!, fit: BoxFit.cover),
                ),
              ElevatedButton(
                child: Text('Salvar'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
