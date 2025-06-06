class Medicine {
  final String id;
  final String name;
  final String strength;
  final String imagePath;
  final int quantity;
  final DateTime expiryDate;

  Medicine({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.strength,
    required this.quantity,
    required this.expiryDate,
  });
}