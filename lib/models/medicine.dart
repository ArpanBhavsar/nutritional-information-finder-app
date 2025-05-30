class Medicine {
  final String id;
  final String imagePath;
  final String name;
  final String strength;
  final int quantity;
  final DateTime expiry;

  Medicine({
    required this.id,
    required this.name,
    required this.strength,
    required this.imagePath,
    required this.quantity,
    required this.expiry,
  });
}