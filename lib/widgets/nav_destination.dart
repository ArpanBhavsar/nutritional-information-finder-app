import 'package:flutter/material.dart';

class NavDestination {
  const NavDestination({required this.icon, required this.label, this.selectedIcon, this.badge});

  final Widget icon;
  final String label;
  final Widget? selectedIcon;
  final Widget? badge;
}
