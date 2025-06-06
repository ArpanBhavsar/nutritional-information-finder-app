import 'package:flutter/material.dart';

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final medicineId = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(appBar: AppBar(title: Text('Medicine Detail')), body: Center(child: Text('Detail screen for Medicine ID: ${medicineId ?? "N/A"}')));
  }
}
