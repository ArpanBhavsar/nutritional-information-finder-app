class Medicine {
  final String id;
  final String name;
  final String strength;
  final String imagePath;
  final int quantity;
  final DateTime expiryDate;
  final String? dosageInformation;
  final String? usageInformation;
  final String? sideEffects;

  Medicine({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.strength,
    required this.quantity,
    required this.expiryDate,
    this.dosageInformation,
    this.usageInformation,
    this.sideEffects,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'strength': strength,
      'imagePath': imagePath,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
      'dosageInformation': dosageInformation,
      'usageInformation': usageInformation,
      'sideEffects': sideEffects,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as String,
      name: map['name'] as String,
      strength: map['strength'] as String,
      imagePath: map['imagePath'] as String,
      quantity: map['quantity'] as int,
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      dosageInformation: map['dosageInformation'] as String?,
      usageInformation: map['usageInformation'] as String?,
      sideEffects: map['sideEffects'] as String?,
    );
  }
}