// Suggested code may be subject to a license. Learn more: ~LicenseLog:1170847113.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:91096487.

import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../widgets/nav_destination.dart';
import 'inventory_list_view.dart';
import 'medicine_scanner_screen.dart'; // Import InventoryListView and Medicine

// Placeholder widgets for the different screens
// Updated InventoryScreen to use InventoryListView
class InventoryScreen extends StatelessWidget {
  // Dummy data for now
  final List<Medicine> dummyInventory = [
    Medicine(id: '1', name: 'Paracetamol', imagePath: 'assets/images/medicine.jpg', strength: '500mg', quantity: 20, expiryDate: DateTime.now().add(Duration(days: 60))),
    Medicine(id: '2', name: 'Ibuprofen', imagePath: 'assets/images/medicine.jpg', strength: '200mg', quantity: 15, expiryDate: DateTime.now().add(Duration(days: 30))),
    Medicine(id: '3', name: 'Amoxicillin', imagePath: 'assets/images/medicine.jpg', strength: '250mg', quantity: 10, expiryDate: DateTime.now().subtract(Duration(days: 5))),
    Medicine(id: '4', name: 'Antacid', imagePath: 'assets/images/medicine.jpg', strength: '10mg', quantity: 50, expiryDate: DateTime.now().add(Duration(days: 180))),
  ];

  @override
  Widget build(BuildContext context) {
    return InventoryListView(inventory: dummyInventory);
  }
}

class PrescriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Prescription Screen'));
  }
}

class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reminders Screen'));
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<NavDestination> _destinations = [
    NavDestination(icon: Icon(Icons.folder_open_outlined), label: 'Inventory', widget: InventoryScreen()),
    NavDestination(icon: Icon(Icons.camera_alt_outlined), label: 'Scan', widget: MedicineScannerScreen()),
    NavDestination(icon: Badge(label: Text('Beta'), child: Icon(Icons.receipt_long_outlined)), label: 'Prescription', widget: PrescriptionScreen()),
    NavDestination(icon: Icon(Icons.alarm_outlined), label: 'Reminders', widget: RemindersScreen()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _destinations.map((destination) => destination.widget).toList()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items:
            _destinations.map((destination) {
              return BottomNavigationBarItem(icon: destination.icon, label: destination.label, backgroundColor: Theme.of(context).primaryColor);
            }).toList(),
      ),
    );
  }
}
