import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../blocs/medicine_reminder/medicine_reminder_bloc.dart';
import '../models/medicine_reminder.dart';
import '../utils/routes.dart';

class MedicineReminderScreen extends StatelessWidget {
  const MedicineReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminders')),
      body: BlocBuilder<MedicineReminderBloc, MedicineReminderState>(
        builder: (context, state) {
          if (state is ReminderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReminderLoaded) {
            if (state.reminders.isEmpty) {
              return const Center(child: Text('No reminders yet. Tap "+" to add one!', style: TextStyle(fontSize: 18, color: Colors.grey)));
            }
            return ListView.builder(
              itemCount: state.reminders.length,
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];
                return _buildReminderTile(context, reminder);
              },
            );
          }
          if (state is ReminderError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addReminderFab',
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addReminder);
        },
        tooltip: 'Add Reminder',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderTile(BuildContext context, MedicineReminder reminder) {
    final timeFormat = MaterialLocalizations.of(context).formatTimeOfDay(reminder.time);
    final days = reminder.days.join(', ');

    return Slidable(
      key: ValueKey(reminder.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) {
              Navigator.pushNamed(context, AppRoutes.editReminder, arguments: reminder);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            context.read<MedicineReminderBloc>().add(DeleteReminder(reminder.id!));
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text("Reminder deleted")));
          },
        ),
        children: [
          SlidableAction(
            onPressed: (ctx) {
              context.read<MedicineReminderBloc>().add(DeleteReminder(reminder.id!));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text("Reminder deleted")));
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.medication_liquid_outlined, size: 40),
        title: Text(reminder.medicineName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Take at $timeFormat on $days'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
