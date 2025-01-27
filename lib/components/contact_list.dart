import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/status.dart';

class ContactList extends StatelessWidget {
  final Status status;

  ContactList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Mock list for now
    final contacts = <Contact>[]; // Replace with Firebase data.

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (ctx, index) {
        final contact = contacts[index];
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
