import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/journal_entry.dart';

class AddJournalScreen extends StatefulWidget {
  final JournalEntry? entry;
  const AddJournalScreen({super.key, this.entry});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool isEditing = false;

  @override
  void initState(){
    super.initState();

  if (widget.entry != null) {
  isEditing = true;
  _titleController.text = widget.entry!.title;
  _contentController.text = widget.entry!.content;
  }
  }

void _saveEntry() async {
  String title = _titleController.text.trim();
  String content = _contentController.text.trim();


  if (title.isEmpty || content.isEmpty)
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Title and content cannot be empty'),
      backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,  // Makes it float above content
        margin: EdgeInsets.all(16),

      ),
    );
    return;
};
  if (isEditing) {
    // Update existing entry
    JournalEntry updatedEntry = JournalEntry(
      id: widget.entry!.id, // Keep the same ID
      title: title,
      content: content,
      date: widget.entry!.date, // Keep the original date
    );
    await DatabaseHelper.instance.updateEntry(updatedEntry);
  } else {
    // Insert new entry
    JournalEntry newEntry = JournalEntry(
      title: title,
      content: content,
      date: DateTime.now().toString().split(' ')[0],
    );
    await DatabaseHelper.instance.insertEntry(newEntry);
  }

  Navigator.pop(context, true); // Return success
}



@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:  Text(isEditing ? 'Edit Journal' : 'New Journal'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child:  Text(isEditing ? 'Update Entry' : 'Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
