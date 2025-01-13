class Task {
  final String id;
  final String taskName;
  final DateTime dueDate;
  final String uid;
  bool isCompleted; // New field to track task completion

  Task({
    required this.id,
    required this.taskName,
    required this.dueDate,
    required this.uid,
    this.isCompleted = false, // Default to false if not specified
  });

  // Convert Task to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'dueDate': dueDate.toIso8601String(),
      'uid': uid,
      'isCompleted': isCompleted, // Include the isCompleted field
    };
  }

  // Create Task object from Firestore document
  static Task fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      taskName: map['taskName'],
      dueDate: DateTime.parse(map['dueDate']),
      uid: map['uid'],
      isCompleted: map['isCompleted'] ??
          false, // Map the isCompleted field, default to false
    );
  }
}
