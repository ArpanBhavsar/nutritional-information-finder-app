// Suggested code may be subject to a license. Learn more: ~LicenseLog:1170847113.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:91096487.

import 'package:flutter/material.dart';
import 'package:myapp/screens/add_medicine_reminder_screen.dart';

import '../widgets/nav_destination.dart';
import 'add_medicine_screen.dart';
import 'inventory_list_view.dart';
import 'medicine_reminder_screen.dart';
import 'medicine_scanner_screen.dart'; // Import InventoryListView and Medicine

// Placeholder widgets for the different screens
// Updated InventoryScreen to use InventoryListView
class InventoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InventoryListView();
  }
}

class PrescriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Prescription Screen'));
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
    NavDestination(icon: Icon(Icons.alarm_outlined), label: 'Reminders', widget: MedicineReminderScreen()),
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
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                heroTag: 'addMedicineFab',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicineScreen()));
                },
                child: Icon(Icons.add),
                tooltip: 'Add New Medicine',
              )
              : _selectedIndex == 3
              ? FloatingActionButton(
                heroTag: 'addMedicineReminderFab',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddMedicineReminderScreen()));
                },
                child: Icon(Icons.add),
                tooltip: 'Add New Medicine Reminder',
              )
              : null,
    );
  }
}
