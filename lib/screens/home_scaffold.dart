import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../widgets/nav_destination.dart';
import 'inventory_list_view.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _selectedIndex = 0;

  static const List<NavDestination> _allDestinations = <NavDestination>[
    NavDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Inventory',
    ),
    NavDestination(
      icon: Icon(Icons.camera_alt_outlined),
      selectedIcon: Icon(Icons.camera_alt),
      label: 'Scan',
    ),
    NavDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Prescription',
      badge: _SmallBetaBadge(),
    ),
    NavDestination(
      icon: Icon(Icons.alarm_outlined),
      selectedIcon: Icon(Icons.alarm),
      label: 'Reminders',
    ),
  ];

  // Dummy list of medicines
  static List<Medicine> medicines = <Medicine>[
    Medicine(
      id: 'med001',
      name: 'Ibuprofen',
      strength: 'Extra',
      quantity: 10,
      imagePath: 'assets/images/advil.webp',
      expiry: DateTime(2026, 05),
    ),
    Medicine(
      id: 'med002',
      name: 'Amoxicillin',
      strength: 'Extra',
      quantity: 10,
      imagePath: 'assets/images/advil.webp',
      expiry: DateTime(2026, 05),
    ),
    Medicine(
      id: 'med003',
      name: 'Lisinopril',
      strength: 'Extra',
      quantity: 10,
      imagePath: 'assets/images/advil.webp',
      expiry: DateTime(2026, 05),
    ),
    Medicine(
      id: 'med004',
      name: 'Cetirizine',
      strength: 'Extra',
      quantity: 10,
      imagePath: 'assets/images/advil.webp',
      expiry: DateTime(2026, 05),
    ),
    Medicine(
      id: 'med005',
      name: 'Omeprazole',
      strength: 'Extra',
      quantity: 10,
      imagePath: 'assets/images/advil.webp',
      expiry: DateTime(2026, 05),
    ),
  ];

  static final List<Widget> _destinationViews = [
    Center(child: InventoryListView(medicines: medicines)),
    const Center(child: Text('Scan Content')),
    const Center(child: Text('Prescription Content')),
    const Center(child: Text('Reminders Content')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _destinationViews),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations:
            _allDestinations.map((NavDestination destination) {
              return NavigationDestination(
                icon:
                    destination.badge != null
                        ? Badge(
                          label: destination.badge,
                          child: destination.icon,
                        )
                        : destination.icon,
                selectedIcon: destination.selectedIcon,
                label: destination.label,
              );
            }).toList(),
      ),
    );
  }
}

class _SmallBetaBadge extends StatelessWidget {
  const _SmallBetaBadge();

  @override
  Widget build(BuildContext context) {
    return const Text('Beta');
  }
}
