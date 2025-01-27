import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/contact.dart';

class ContactsProvider with ChangeNotifier {
  // final List<Contact> _contacts = [];
  static final Map<String, Contact> _contactsMap = {};

  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('contacts');

  Map<String, Contact> get contacts => {..._contactsMap};

  Future<Map<String, Contact>> fetchContacts() async {
    try {
      final snapshot = await _dbRef.get();
      if (!snapshot.exists) {
        throw 'Nenhum contato encontrado.';
      }
      _contactsMap.clear();
      // Converte o snapshot.value para Map<String, dynamic>
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // Itera pelo mapa e converte os valores aninhados
      data.forEach((key, value) {
        final contact = Contact.fromJson(value);
        _contactsMap.putIfAbsent(key, () => contact);  
      });
      notifyListeners();
      return contacts;
    } catch (e) {
      print('Erro ao buscar contatos: $e');
      rethrow;
    }
  }

  Future<MapEntry<String, Contact>> addContact(Contact contact) async {
    try {
      final newRef = _dbRef.push();
      if (newRef.key == null) {
        throw 'Erro ao gerar chave para novo contato.';
      }
      await newRef.set({
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
      final contactEntry = MapEntry(newRef.key!, contact);
      _contactsMap.putIfAbsent(contactEntry.key, () => contactEntry.value);
      notifyListeners();
      return contactEntry;
    } catch (e) {
      print('Erro ao adicionar contato: $e');
      rethrow;
    }
  }

  Future<void> updateContact(MapEntry<String, Contact> contactEntry) async {
    try {
      await _dbRef.child(contactEntry.key).update({
        'firstName': contactEntry.value.firstName,
        'lastName': contactEntry.value.lastName,
        'phone': contactEntry.value.phone,
        'email': contactEntry.value.email,
        'status': contactEntry.value.status.name,
        'photoUrl': contactEntry.value.photoUrl,
        'location': {
          'latitude': contactEntry.value.location.latitude,
          'longitude': contactEntry.value.location.longitude,
        },
      });
      _contactsMap.update(contactEntry.key, (_) => contactEntry.value);
      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar contato: $e');
    }
  }

  Future<void> deleteContact(String key) async {
    try {
      await _dbRef.child(key).remove();
      _contactsMap.remove(key);
      notifyListeners();
    } catch (e) {
      print('Erro ao deletar contato: $e');
      rethrow;
    }
  }
}
