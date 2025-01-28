import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/contact.dart';
import '../models/status.dart';
import '../models/location.dart';
import '../provider/contacts_provider.dart';
import '../utils/location_util.dart';
import '../services/image_picker_service.dart';
import '../services/image_store_service.dart';
import 'map_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final String contactKey;

  ContactDetailScreen({required this.contactKey});

  @override
  _ContactDetailScreenState createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late Contact _contact;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _contact = Provider.of<ContactsProvider>(context, listen: false)
        .contacts[widget.contactKey]!;
  }

  Future<void> _updateLocation() async {
    final LatLng? selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(),
      ),
    );

    if (selectedPosition != null) {
      setState(() {
        _contact.location = Location(
          latitude: selectedPosition.latitude.toString(),
          longitude: selectedPosition.longitude.toString(),
        );
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await Provider.of<ContactsProvider>(context, listen: false)
          .updateContact(MapEntry(widget.contactKey, _contact));
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato atualizado com sucesso!')),
      );
    }
  }

  Future<void> _changePhoto() async {
    final file = await ImagePickerService.pickImageFromGallery();
    final url = await ImageStoreService.storeImage(file);
    setState(() => _contact.photoUrl = url);
  }

  Future<void> _makeCall() async {
    final url = 'tel:${_contact.phone}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível realizar a chamada.';
    }
  }

  Future<void> _sendEmail() async {
    final url = 'mailto:${_contact.email}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Não foi possível abrir o app de e-mail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.firstName),
        backgroundColor: _isEditing ? Colors.orange : Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isEditing ? _changePhoto : null,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _contact.photoUrl.isNotEmpty
                        ? NetworkImage(_contact.photoUrl)
                        : null,
                    child: _contact.photoUrl.isEmpty
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (_isEditing)
                TextFormField(
                  initialValue: _contact.firstName,
                  decoration: InputDecoration(labelText: 'Nome'),
                  onSaved: (value) => _contact.firstName = value!,
                  validator: (value) =>
                      value!.isEmpty ? 'Por favor, insira um nome.' : null,
                ),
              if (_isEditing)
                TextFormField(
                  initialValue: _contact.lastName,
                  decoration: InputDecoration(labelText: 'Sobrenome'),
                  onSaved: (value) => _contact.lastName = value!,
                ),
              if (_isEditing)
                TextFormField(
                  initialValue: _contact.phone,
                  decoration: InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _contact.phone = value!,
                ),
              GestureDetector(
                onTap: !_isEditing ? _sendEmail : null,
                child: TextFormField(
                  initialValue: _contact.email,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  style: TextStyle(
                    decoration: !_isEditing ? TextDecoration.underline : null,
                    color: !_isEditing ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (_isEditing)
                ElevatedButton(
                  child: Text('Mudar Localização'),
                  onPressed: _updateLocation,
                ),
              Wrap(
                spacing: 10,
                runSpacing: 5,
                children: [
                  if (_contact.location.latitude.isNotEmpty)
                    Text(
                      'Lat: ${_contact.location.latitude}, Long: ${_contact.location.longitude}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                ],
              ),
              SizedBox(height: 10),
              FutureBuilder<String>(
                future: LocationUtil.getAddressFromCoordinates(
                  double.parse(_contact.location.latitude),
                  double.parse(_contact.location.longitude),
                ),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Carregando endereço...', style: TextStyle(fontSize: 14));
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar endereço', style: TextStyle(color: Colors.red, fontSize: 14));
                  } else {
                    return Text(
                      'Endereço: ${snapshot.data}',
                      style: TextStyle(fontSize: 14),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? null
          : FloatingActionButton(
              child: Icon(Icons.phone),
              onPressed: _makeCall,
            ),
    );
  }
}
