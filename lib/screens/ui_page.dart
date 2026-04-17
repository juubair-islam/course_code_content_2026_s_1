import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firebase
import 'package:flutter_ui_class/screens/add_task_page.dart';
import 'package:flutter_ui_class/widgets/task_card_widget.dart';

class UiPage extends StatefulWidget {
  const UiPage({super.key});

  @override
  State<UiPage> createState() => _UiPageState();
}

class _UiPageState extends State<UiPage> {
  @override
  Widget build(BuildContext context) {
    print("Building UI Page...");

    return Scaffold(
      appBar: AppBar(
        title: const Text("UI PAGE"),
        backgroundColor: Colors.purpleAccent,
      ),

      // 🔥 REPLACED PROVIDER WITH STREAMBUILDER FOR REAL-TIME FIREBASE DATA 🔥
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tasks yet. Add one!"));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskDoc = tasks[index];
              final data = taskDoc.data() as Map<String, dynamic>;
              final taskId = taskDoc.id;

              // Wrapped in Dismissible so you can swipe to delete!
              return Dismissible(
                key: Key(taskId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  // 🔥 DIRECT FIREBASE DELETE LOGIC 🔥
                  try {
                    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Task Deleted"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    print("Error deleting task: $e");
                  }
                },
                child: TaskCardWidget(
                  title: data['title'] ?? 'No Title',
                  subtitle: data['subtitle'] ?? '',
                  // Convert integer icon code back to an IconData object if it exists
                  icon: data['iconCode'] != null 
                      ? IconData(data['iconCode'], fontFamily: 'MaterialIcons') 
                      : Icons.task, 
                ),
              );
            },
          );
        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AddTaskPage()));
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}