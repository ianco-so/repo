import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'models/contact.dart';
import 'models/status.dart';
import 'models/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Agenda',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactTabs(),
    );
  }
}

class ContactTabs extends StatefulWidget {
  @override
  _ContactTabsState createState() => _ContactTabsState();
}

class _ContactTabsState extends State<ContactTabs> {
  final List<Contact> _contacts = [];

  void _addContact(Contact contact) {
    setState(() {
      _contacts.add(contact);
    });
    // Save to Firebase
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('contacts');
    dbRef.push().set({
      'firstName': contact.firstName,
      'lastName': contact.lastName,
      'email': contact.email,
      'phone': contact.phone,
      'status': contact.status.index,
      'photoUrl': contact.photoUrl,
    });
  }

  void _showStudentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Informações do Aluno'),
        content: Text('Nome: João Silva\nMatrícula: 2023123456'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Minha Agenda'),
          actions: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () => _showStudentInfo(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Favoritos'),
              Tab(text: 'Bloqueados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ContactList(_contacts, Status.NORMAL),
            ContactList(_contacts, Status.FAVORITE),
            ContactList(_contacts, Status.BLOCKED),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddContactScreen(onAddContact: _addContact),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ContactList extends StatelessWidget {
  final List<Contact> contacts;
  final Status status;

  ContactList(this.contacts, this.status);

  @override
  Widget build(BuildContext context) {
    final filteredContacts = contacts.where((c) => c.status == status).toList();

    return ListView.builder(
      itemCount: filteredContacts.length,
      itemBuilder: (ctx, index) {
        final contact = filteredContacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: contact.photoUrl.isNotEmpty
                ? NetworkImage(contact.photoUrl)
                : null,
            child: contact.photoUrl.isEmpty ? Icon(Icons.person) : null,
          ),
          title: Text(contact.firstName + ' ' + contact.lastName),
          subtitle: Text(contact.phone),
        );
      },
    );
  }
}

class AddContactScreen extends StatelessWidget {
  final Function(Contact) onAddContact;

  AddContactScreen({required this.onAddContact});

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome.';
                  }
                  return null;
                },
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
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Salvar'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    onAddContact(Contact(
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      phone: _phoneController.text,
                      email: '',
                      status: Status.NORMAL,
                      photoUrl: '', 
                      location: Location(latitude: 0, longitude: 0),
                    ));
                    Navigator.of(context).pop();
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
