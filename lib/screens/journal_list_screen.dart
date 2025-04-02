import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/journal_entry.dart';
import 'add_journal_screen.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}


class _JournalListScreenState extends State<JournalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JournalEntry> _allEntries = [];
  List<JournalEntry> _filteredEntries = [];
  late Future<List<JournalEntry>> _journalEntries;


  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  void _loadJournalEntries() {
    setState(() {
      _journalEntries = DatabaseHelper.instance.getEntries();
      _journalEntries.then((entries) {
        _allEntries = entries;
        _filteredEntries = entries;
      });
    });
  }
  void _filterEntries(String query) {
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        return entry.title.toLowerCase().contains(query.toLowerCase()) ||
            entry.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }


  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Don't worry", style: TextStyle(color: Colors.teal)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteEntry(id);
              Navigator.pop(context);
              _loadJournalEntries();
            },
            child: const Text('Sure, Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search journals...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
                onPressed: () {
                _searchController.clear();
                _filterEntries('');
                },

            ),
          ),
          onChanged: _filterEntries,
        ),
        // title: const Text('Daily Journal')
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: _journalEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if //(!snapshot.hasData || snapshot.data!.isEmpty)
          (_filteredEntries.isEmpty)
          {
            return const Center(child: Text( 'No results found'//'No journal entries yet.'
            ));
          } else {
            return ListView.builder(
              itemCount: _filteredEntries.length,//snapshot.data!.length,
              itemBuilder: (context, index) {
                JournalEntry entry = _filteredEntries[index];
                //snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.date),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (entry.id != null) {
                          _confirmDelete(entry.id!);
                        }
                      },
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddJournalScreen(entry: entry),
                        ),
                      );
                      if (result == true) {
                        _loadJournalEntries();
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJournalScreen()),
          );
          if (result == true) {
            _loadJournalEntries();
          }
        },
      ),
    );
  }
}
