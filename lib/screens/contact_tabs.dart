import 'package:flutter/material.dart';
import '../models/status.dart';
import '../components/contact_list.dart';
import 'add_contact_screen.dart';

class ContactTabs extends StatefulWidget {
  @override
  _ContactTabsState createState() => _ContactTabsState();
}

class _ContactTabsState extends State<ContactTabs> {
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
            ContactList(status: Status.NORMAL),
            ContactList(status: Status.FAVORITE),
            ContactList(status: Status.BLOCKED),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddContactScreen()),
            );
          },
        ),
      ),
    );
  }

  void _showStudentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Informações do Aluno'),
        content: Text('Nome: Ianco Soares\nMatrícula: 20210054067'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
