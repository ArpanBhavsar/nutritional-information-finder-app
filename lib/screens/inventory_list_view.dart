import 'package:flutter/material.dart';

import '../models/medicine.dart';

// You might need to create an EmptyState widget or use a package
// import 'package:medicine_tracker_app/widgets/empty_state.dart';

class InventoryListView extends StatelessWidget {
  final List<Medicine> medicines;

  const InventoryListView({Key? key, required this.medicines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      // Assuming you have an EmptyState widget that takes an image path
      // You need to ensure 'assets/images/empty_box.png' exists
      // and is listed in pubspec.yaml under assets.
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your EmptyState widget if available
            // Image.asset('assets/images/empty_box.png'),
            Icon(Icons.inbox, size: 80.0, color: Colors.grey),
            SizedBox(height: 16.0),
            Text(
              'Your inventory is empty!',
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final medicine = medicines[index];
          // Determine chip color based on expiry date
          final now = DateTime.now();
          final difference = medicine.expiry.difference(now).inDays;
          Color chipColor = Colors.green;
          if (difference < 30 && difference >= 0) {
            chipColor = Colors.amber;
          } else if (difference < 0) {
            chipColor = Colors.red;
          }

          return ListTile(
            leading: Hero(
              tag: 'medicineImage_${medicine.id}',
              child: CircleAvatar(
                child: Image.asset(medicine.imagePath, fit: BoxFit.contain,),
              ),
            ),
            title: Text(medicine.name),
            subtitle: Text('${medicine.strength}, Quantity: ${medicine.quantity}'),
            trailing: Chip(
              label: Text(
                'Exp: ${medicine.expiry.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: chipColor,
            ),
            onTap: () {
              // Navigate to detail screen
              // You will need to define this route in your application's routing
              Navigator.pushNamed(context, '/inventory/detail', arguments: medicine);
            },
          );
        },
      );
    }
  }
}