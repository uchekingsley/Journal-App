import 'package:flutter/material.dart';
import 'screens/journal_list_screen.dart';

void main() {
  runApp(JournalApp());
}

class JournalApp extends StatelessWidget {
  const JournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Journal',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,),
        home: JournalListScreen(),
      );
    }
}


