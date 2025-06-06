import 'dart:io';

import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../utils/routes.dart';

// Placeholder Medicine class (replace with your actual model)

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User needs to add this image asset
          Image.asset('assets/images/empty_box.png', width: 150, height: 150),
          const SizedBox(height: 20),
          Text('Your inventory is empty.'),
          const SizedBox(height: 10),
          Text('Add your first medicine to get started.'),
        ],
      ),
    );
  }
}

class InventoryListView extends StatelessWidget {
  final List<Medicine> inventory;

  const InventoryListView({Key? key, required this.inventory}) : super(key: key);

  Color _getExpiryChipColor(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red[700]!;
    } else if (difference <= 30) {
      return Colors.red;
    } else if (difference <= 90) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (inventory.isEmpty) {
      return const EmptyState();
    } else {
      return ListView.builder(
        itemCount: inventory.length,
        itemBuilder: (context, index) {
          final medicine = inventory[index];
          
          Widget leadingWidget;
          if (medicine.imagePath.isNotEmpty && File(medicine.imagePath).existsSync()) {
            leadingWidget = CircleAvatar(
              backgroundImage: FileImage(File(medicine.imagePath)),
            );
          } else {
            leadingWidget = const CircleAvatar(
              child: Icon(Icons.medical_services),
            );
          }

          return ListTile(
            leading: leadingWidget,
            title: Text(medicine.name),
            subtitle: Text('${medicine.strength}, Quantity: ${medicine.quantity}'),
            trailing: Chip(
              label: Text('Exp: ${medicine.expiryDate.toLocal().toString().split(' ')[0]}'),
              backgroundColor: _getExpiryChipColor(medicine.expiryDate),
              labelStyle: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // Navigate to detail screen, passing medicine id or object
              Navigator.pushNamed(context, AppRoutes.inventoryDetail, arguments: medicine.id);
            },
          );
        },
      );
    }
  }
}
