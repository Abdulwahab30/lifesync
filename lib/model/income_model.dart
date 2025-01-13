class IncomeEntry {
  final String id;
  final String description;
  final double amount;
  final String type;
  final String uid; // User ID
  final DateTime date; // New date field

  IncomeEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.uid,
    required this.date, // Include date in the constructor
  });

  // Convert IncomeEntry to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'uid': uid,
      'date': date.toIso8601String(), // Convert date to ISO string for Firebase
    };
  }

  // Create IncomeEntry object from Firestore document
  static IncomeEntry fromMap(Map<String, dynamic> map, String documentId) {
    return IncomeEntry(
      id: documentId,
      description: map['description'],
      amount: map['amount'],
      type: map['type'],
      uid: map['uid'],
      date: DateTime.parse(map['date']), // Parse ISO string back to DateTime
    );
  }
}
