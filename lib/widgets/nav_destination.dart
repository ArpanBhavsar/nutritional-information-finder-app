import 'package:flutter/material.dart';

class NavDestination {
  const NavDestination({
    required this.icon,
    required this.label,
    required this.widget,
  });

  final Widget icon;
  final String label;
  final Widget widget;
}
