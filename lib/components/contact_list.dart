import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/contacts_provider.dart';
import '../models/status.dart';
import '../screens/contact_details_screen.dart';

class ContactList extends StatefulWidget {
  final Status status;

  ContactList({required this.status});

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  late Future<void> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = Provider.of<ContactsProvider>(context, listen: false).fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _contactsFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar contatos.'));
        } else {
          return Consumer<ContactsProvider>(
            builder: (ctx, contactsProvider, child) {
              final contactsMap = contactsProvider.contacts;
              final filteredContacts = contactsMap.entries
                  .where((entry) => entry.value.status == widget.status);

              if (filteredContacts.isEmpty) {
                return Center(child: Text('Nenhum contato disponível.'));
              }

              return ListView(
                children: filteredContacts.map((entry) {
                  final contactKey = entry.key;
                  final contact = entry.value;

                  return Dismissible(
                    key: Key(contactKey),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      contactsProvider.deleteContact(contactKey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${contact.firstName} foi removido.')),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: contact.photoUrl.isNotEmpty
                            ? NetworkImage(contact.photoUrl)
                            : null,
                        child: contact.photoUrl.isEmpty ? Icon(Icons.person) : null,
                      ),
                      title: Text('${contact.firstName} ${contact.lastName}'),
                      subtitle: Text(contact.phone),
                      onTap: () {
                        // Navegar para detalhes do contato
                        // Navigator.of(context).pushNamed(
                        //   '/contact-details',
                        //   arguments: contactKey,
                        // );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ContactDetailScreen(contactKey: contactKey),
                            ),
                          );

                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        }
      },
    );
  }
}
