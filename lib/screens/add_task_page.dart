import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firebase
import 'package:flutter_ui_class/utils/validators.dart';
import 'package:flutter_ui_class/widgets/core_input_field.dart';
import 'package:flutter_ui_class/widgets/password_input_filed.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Removed TaskManagementProvider because we are using Firebase directly now!

  @override
  void dispose() {
    _titleController.clear();
    _assignedToController.clear();
    _phoneNumberController.clear();
    _passwordController.clear();
    _descriptionController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          // Changed Column to ListView so the keyboard doesn't cover the inputs and cause errors
          child: ListView(
            children: [
              CoreInputField(
                controller: _titleController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                labelText: "Task Title",
                validator: CustomValidators.validateTaskTitle,
              ),
              const SizedBox(height: 20),
              CoreInputField(
                controller: _assignedToController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                labelText: "Assigned To",
                validator: CustomValidators.validateAssignedTo,
              ),
              const SizedBox(height: 20),
              CoreInputField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLines: 1,
                labelText: "Phone Number",
                validator: CustomValidators.validatePhoneNumber,
              ),
              const SizedBox(height: 20),
              PasswordInputFiled(controller: _passwordController),
              const SizedBox(height: 40),
              CoreInputField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                labelText: "Task Description",
                validator: CustomValidators.validateDescription,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: ElevatedButton(
          // Made this function async to handle Firebase
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final String taskDetails =
                  "Assigned to: ${_assignedToController.text} \nPhone: ${_phoneNumberController.text} \nDescription: ${_descriptionController.text} \n \n The task Password is ${_passwordController.text}";

              // 🔥 DIRECT FIREBASE SAVE LOGIC 🔥
              try {
                await FirebaseFirestore.instance.collection('tasks').add({
                  'title': _titleController.text,
                  'subtitle': taskDetails,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                // context.mounted prevents a crash if the user closes the page before Firebase finishes saving
                if (context.mounted) {
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Task added successfully!",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print("Error adding task to Firebase: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to add task: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text("Add Task"),
        ),
      ),
    );
  }
}