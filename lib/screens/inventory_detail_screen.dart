import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/medicine_inventory/medicine_inventory_bloc.dart';
import '../blocs/medicine_inventory/medicine_inventory_event.dart';
import '../blocs/medicine_inventory/medicine_inventory_state.dart';

class InventoryDetailScreen extends StatefulWidget {
  const InventoryDetailScreen({Key? key}) : super(key: key);

  @override
  _InventoryDetailScreenState createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  String? _medicineId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      if (_medicineId != args) {
        _medicineId = args;
        context.read<MedicineInventoryBloc>().add(LoadMedicineById(_medicineId!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<MedicineInventoryBloc>().add(LoadMedicines());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medicine Detail'),
        ),
        body: BlocBuilder<MedicineInventoryBloc, MedicineInventoryState>(
          builder: (context, state) {
            if (state is MedicineInventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MedicineLoaded) {
              final medicine = state.medicine;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (medicine.imagePath != null && medicine.imagePath!.isNotEmpty)
                      Center(
                        child: Image.file(
                          File(medicine.imagePath!),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildDetailItem('Medicine Name', medicine.name),
                    _buildDetailItem('Strength', medicine.strength),
                    _buildDetailItem('Quantity', medicine.quantity.toString()),
                    _buildDetailItem(
                      'Expiry Date',
                      DateFormat.yMMMd().format(medicine.expiryDate),
                    ),
                    if (medicine.dosage != null)
                      _buildDetailItem('Dosage', medicine.dosage!),
                    if (medicine.usage != null)
                      _buildDetailItem('Usage', medicine.usage!),
                    if (medicine.sideEffects != null)
                      _buildDetailItem('Side Effects', medicine.sideEffects!),
                  ],
                ),
              );
            } else if (state is MedicineInventoryError) {
              return Center(child: Text(state.message));
            }
            // Initial state or when no medicineId is provided
            return const Center(child: Text('Select a medicine to see details.'));
          },
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }
}