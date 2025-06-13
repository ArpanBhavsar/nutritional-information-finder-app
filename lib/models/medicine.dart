class Medicine {
  final String id;
  final String name;
  final String strength;
  final String? imagePath;
  final int quantity;
  final DateTime expiryDate;
  final String? dosage;
  final String? usage;
  final String? sideEffects;

  Medicine({required this.id, required this.name, required this.imagePath, required this.strength, required this.quantity, required this.expiryDate, this.dosage, this.usage, this.sideEffects});

  // Convert Medicine object to a Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'strength': strength,
      'imagePath': imagePath,
      'quantity': quantity,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'dosage': dosage,
      'usage': usage,
      'sideEffects': sideEffects,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      strength: map['strength'],
      imagePath: map['imagePath'],
      quantity: map['quantity'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      dosage: map['dosage'],
      usage: map['usage'],
      sideEffects: map['sideEffects'],
    );
  }
}
