import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/medicine_reminder/medicine_reminder_bloc.dart';
import '../data/database_service.dart';
import '../models/medicine.dart';
import '../models/medicine_reminder.dart';


class EditMedicineReminderScreen extends StatefulWidget {
  final MedicineReminder reminder;
  const EditMedicineReminderScreen({super.key, required this.reminder});

  @override
  State<EditMedicineReminderScreen> createState() => _EditMedicineReminderScreenState();
}

class _EditMedicineReminderScreenState extends State<EditMedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _selectedTime;
  Medicine? _selectedMedicine;
  List<Medicine> _medicines = [];
  late final Set<String> _selectedDays;

  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.reminder.time;
    _selectedDays = widget.reminder.days.toSet();
    _loadMedicinesAndSetInitial();
  }

  Future<void> _loadMedicinesAndSetInitial() async {
    final medicines = await DatabaseService().getMedicines();
    setState(() {
      _medicines = medicines;
      // Find the medicine object that matches the reminder's medicineId
      _selectedMedicine = _medicines.firstWhere(
            (med) => med.id == widget.reminder.medicineId,
        orElse: () => _medicines.first, // Fallback, though should not happen
      );
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _onDaySelected(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _updateReminder() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day.')),
        );
        return;
      }

      final updatedReminder = widget.reminder.copyWith(
        medicineId: _selectedMedicine!.id,
        medicineName: _selectedMedicine!.name,
        time: _selectedTime,
        days: _selectedDays.toList(),
      );

      context.read<MedicineReminderBloc>().add(UpdateReminder(updatedReminder));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Reminder')),
      body: _medicines.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Dropdown
              DropdownButtonFormField<Medicine>(
                value: _selectedMedicine,
                items: _medicines.map((Medicine medicine) {
                  return DropdownMenuItem<Medicine>(
                    value: medicine,
                    child: Text(medicine.name),
                  );
                }).toList(),
                onChanged: (Medicine? newValue) {
                  setState(() {
                    _selectedMedicine = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a medicine' : null,
                decoration: const InputDecoration(
                  labelText: 'Medicine',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Time Picker
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.timer_outlined),
                onTap: () => _selectTime(context),
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Day Selector
              const Text('Repeat on', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('Everyday'),
                    selected: _selectedDays.length == _weekdays.length || _selectedDays.contains('Everyday'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.clear();
                          _selectedDays.add('Everyday');
                        } else {
                          _selectedDays.remove('Everyday');
                        }
                      });
                    },
                  ),
                  ..._weekdays.map((day) {
                    return FilterChip(
                      label: Text(day.substring(0,3)),
                      selected: _selectedDays.contains(day),
                      onSelected: (_selectedDays.contains('Everyday')) ? null : (selected) {
                        _onDaySelected(day);
                      },
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateReminder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Update Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}