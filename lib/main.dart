import 'package:flutter/material.dart';
// import 'package:repo/screens/contact_details_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'provider/contacts_provider.dart';
import 'screens/contact_tabs.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Minha Agenda',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: ContactTabs(),
        // routes: {
        //   '/contact-details': (ctx) => ContactDetailScreen(contactKey: ''),
        // }
      ),
    );
  }
}
