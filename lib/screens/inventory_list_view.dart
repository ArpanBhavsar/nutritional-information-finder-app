import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../blocs/medicine_inventory/medicine_inventory_bloc.dart';
import '../blocs/medicine_inventory/medicine_inventory_event.dart';
import '../blocs/medicine_inventory/medicine_inventory_state.dart';
import '../utils/routes.dart';
import 'edit_medicine_screen.dart';

class InventoryListView extends StatefulWidget {
  const InventoryListView({Key? key}) : super(key: key);

  @override
  _InventoryListViewState createState() => _InventoryListViewState();
}

class _InventoryListViewState extends State<InventoryListView> {
  @override
  void initState() {
    super.initState();
    context.read<MedicineInventoryBloc>().add(LoadMedicines());
  }

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
    return BlocBuilder<MedicineInventoryBloc, MedicineInventoryState>(
      builder: (context, state) {
        if (state is MedicineInventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MedicineInventoryLoaded) {
          if (state.medicines.isEmpty) {
            return const EmptyState();
          }
          return ListView.builder(
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final medicine = state.medicines[index];
              return Slidable(
                key: ValueKey(medicine.id),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMedicineScreen(medicine: medicine),
                          ),
                        );
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {
                    context.read<MedicineInventoryBloc>().add(DeleteMedicine(medicine.id));
                  }),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        context.read<MedicineInventoryBloc>().add(DeleteMedicine(medicine.id));
                      },
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (medicine.imagePath != null && medicine.imagePath!.isNotEmpty)
                        ? FileImage(File(medicine.imagePath!))
                        : null,
                    child: (medicine.imagePath == null || medicine.imagePath!.isEmpty)
                        ? Text(medicine.name.isNotEmpty ? medicine.name[0].toUpperCase() : '')
                        : null,
                  ),
                  title: Text(medicine.name),
                  subtitle: Text('${medicine.strength}, Quantity: ${medicine.quantity}'),
                  trailing: Chip(
                    label: Text('Exp: ${medicine.expiryDate.toLocal().toString().split(' ')[0]}'),
                    backgroundColor: _getExpiryChipColor(medicine.expiryDate),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.inventoryDetail, arguments: medicine.id);
                  },
                ),
              );
            },
          );
        } else if (state is MedicineInventoryError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Something went wrong.'));
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty_box.png', width: 150, height: 150),
          const SizedBox(height: 20),
          Text(
            'Your inventory is empty.',
          ),
          const SizedBox(height: 10),
          Text(
            'Add your first medicine to get started.',
          ),
        ],
      ),
    );
  }
}
