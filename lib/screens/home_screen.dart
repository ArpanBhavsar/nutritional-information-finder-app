// Suggested code may be subject to a license. Learn more: ~LicenseLog:1170847113.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:91096487.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/medicine_database/medicine_database_bloc.dart';
import '../blocs/medicine_database/medicine_database_event.dart';
import '../blocs/medicine_database/medicine_database_state.dart';
import '../models/medicine.dart';
import '../utils/database_helper.dart';
import '../widgets/nav_destination.dart';
import 'add_medicine_screen.dart';
import 'inventory_list_view.dart';
import 'medicine_scanner_screen.dart'; // Import InventoryListView and Medicine

// Placeholder widgets for the different screens
// Updated InventoryScreen to use InventoryListView
class InventoryScreen extends StatelessWidget {
  final List<Medicine> inventory;

  const InventoryScreen({Key? key, required this.inventory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InventoryListView(inventory: inventory);
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineDatabaseBloc(DatabaseHelper.instance)
        ..add(InitializeDatabaseEvent()), // Initialize DB and load initial data
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _selectedIndex = 0;

  // _inventory will now be driven by Bloc state
  // late final List<NavDestination> _destinations; // This will be built dynamically

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddMedicine(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
    );

    // If AddMedicineScreen pops with true, it means a medicine was added successfully
    if (result == true) {
      context.read<MedicineDatabaseBloc>().add(LoadMedicinesFromDbEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineDatabaseBloc, MedicineDatabaseState>(
      builder: (context, state) {
        List<Medicine> currentInventory = [];
        if (state is MedicineDatabaseLoaded) {
          currentInventory = state.medicines;
        }
        // else if (state is MedicineDatabaseLoading && _selectedIndex == 0) {
        //   // Optionally show a loading indicator for the inventory screen
        // }

        final destinations = [
          NavDestination(icon: const Icon(Icons.folder_open_outlined), label: 'Inventory', widget: InventoryScreen(inventory: currentInventory)),
          NavDestination(icon: const Icon(Icons.camera_alt_outlined), label: 'Scan', widget: const MedicineScannerScreen()),
          NavDestination(icon: const Badge(label: Text('Beta'), child: Icon(Icons.receipt_long_outlined)), label: 'Prescription', widget: PrescriptionScreen()),
          NavDestination(icon: const Icon(Icons.alarm_outlined), label: 'Reminders', widget: RemindersScreen()),
        ];

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: destinations.map((destination) => destination.widget).toList()),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items:
            destinations.map((destination) { // Use the local destinations variable from BlocBuilder
              return BottomNavigationBarItem(icon: destination.icon, label: destination.label, backgroundColor: Theme.of(context).primaryColor);
            }).toList(),
      ),
      floatingActionButton: _selectedIndex == 0 // Show FAB only on the Inventory screen
          ? FloatingActionButton(
              onPressed: () => _navigateToAddMedicine(context),
              child: const Icon(Icons.add),
            )
          : null,
        );
      },
    );
  }
}
