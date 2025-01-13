import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:todo_app/model/income_model.dart';
import 'package:todo_app/model/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<void> addTask(String taskName, DateTime dueDate) async {
    if (currentUser != null) {
      final task = Task(
        id: _db.collection('tasks').doc().id,
        taskName: taskName,
        dueDate: dueDate,
        uid: currentUser!.uid,
        isCompleted: false, // New tasks are not completed by default
      );
      await _db.collection('tasks').doc(task.id).set(task.toMap());
    }
  }

//retrieve
  // Get tasks for the current user
  Stream<List<Task>> getTasksForUser() {
    if (currentUser != null) {
      return _db
          .collection('tasks')
          .where('uid', isEqualTo: currentUser!.uid) // Filter by user ID
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Task.fromMap(doc.data(), doc.id))
              .toList());
    }
    return Stream.empty();
  }

  //update
  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      print("Error updating task: $e");
    }
  }

//delete
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  //income management
  // Add an income entry

  Future<void> addIncomeEntry(
      String description, double amount, String type) async {
    if (currentUser != null) {
      final entry = IncomeEntry(
        id: _db.collection('income_entries').doc().id,
        description: description,
        amount: amount,
        type: type,
        uid: currentUser!.uid,
        date: DateTime.now(), // Save current date/time
      );
      await _db.collection('income_entries').doc(entry.id).set(entry.toMap());
    }
  }

// Stream of income entries
  Stream<List<IncomeEntry>> getIncomeEntriesForUser() {
    if (currentUser != null) {
      return _db
          .collection('income_entries')
          .where('uid', isEqualTo: currentUser!.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => IncomeEntry.fromMap(doc.data(), doc.id))
              .toList());
    }
    return Stream.empty();
  }
}
