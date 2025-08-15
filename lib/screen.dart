// import 'package:todo_app/controller/app_controller.dart';
// import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/boxes/boxes.dart';
import 'package:todo_app/models/notes_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final Color _bgDark = const Color(0xFF0A0A0A);
  final Color _cardDark = const Color(0xFF121212);
  final Color _buttonBlue = const Color(0xFF1976D2);
  final Color _buttonRed = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    // AppController appController = Get.put(AppController());

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "📝 My Todo List",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<Box<NotesModel>>(
              valueListenable: Boxes.getData().listenable(),
              builder: (context, box, _) {
                var data = box.values.toList().cast<NotesModel>();
                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "No notes yet. Tap ➕ to add one!",
                      style: TextStyle(fontSize: 16, color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _cardDark,
                        border: Border.all(color: _buttonBlue, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: Text(
                          data[index].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          data[index].description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: _buttonBlue),
                              onPressed: () {
                                _editNoteDialog(context, data[index]);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                data[index].delete();
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _showBottomDrawer(context, data[index]);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMyDialog(context);
        },
        backgroundColor: _buttonBlue,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "➕ Add Note",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 180,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter Title'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            _styledButton("Add 📝", _buttonBlue, () {
              final data = NotesModel(
                title: titleController.text,
                description: descriptionController.text,
                dateTime: DateTime.now(),
              );
              final box = Boxes.getData();
              box.add(data);
              titleController.clear();
              descriptionController.clear();
              Navigator.pop(context);
            }),
          ],
        );
      },
    );
  }

  Future<void> _editNoteDialog(BuildContext context, NotesModel note) {
    titleController.text = note.title;
    descriptionController.text = note.description;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "✏️ Edit Note",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter Title'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Enter Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _styledButton("Update ✏️", _buttonBlue, () {
                  note.title = titleController.text;
                  note.description = descriptionController.text;
                  note.save();
                  titleController.clear();
                  descriptionController.clear();
                  Navigator.pop(context);
                }),
                const SizedBox(width: 12),
                _styledButton("Cancel ❌", Colors.grey, () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showBottomDrawer(BuildContext context, NotesModel note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                note.description,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                "Created: ${DateFormat('dd/MM/yyyy – hh:mm a').format(note.dateTime ?? DateTime.now())}",
                style: const TextStyle(fontSize: 14, color: Colors.white38),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _styledButton("Edit ✏️", _buttonBlue, () {
                    Navigator.pop(context);
                    _editNoteDialog(context, note);
                  }),
                  const SizedBox(width: 10),
                  _styledButton("Delete 🗑️", _buttonRed, () {
                    note.delete();
                    Navigator.pop(context);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _styledButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white24, width: 0.6),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _buttonBlue, width: 1),
      ),
    );
  }
}
