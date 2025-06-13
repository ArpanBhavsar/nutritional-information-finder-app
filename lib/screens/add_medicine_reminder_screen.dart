import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/medicine_reminder/medicine_reminder_bloc.dart';
import '../data/database_service.dart';
import '../models/medicine.dart';
import '../models/medicine_reminder.dart';

class AddMedicineReminderScreen extends StatefulWidget {
  const AddMedicineReminderScreen({super.key});

  @override
  State<AddMedicineReminderScreen> createState() => _AddMedicineReminderScreenState();
}

class _AddMedicineReminderScreenState extends State<AddMedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _selectedTime;
  Medicine? _selectedMedicine;
  List<Medicine> _medicines = [];
  final Set<String> _selectedDays = {};

  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _selectedTime = TimeOfDay.now();
  }

  Future<void> _loadMedicines() async {
    final medicines = await DatabaseService().getMedicines();
    setState(() {
      _medicines = medicines;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
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

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one day.')));
        return;
      }

      final newReminder = MedicineReminder(medicineId: _selectedMedicine!.id, medicineName: _selectedMedicine!.name, time: _selectedTime!, days: _selectedDays.toList());

      context.read<MedicineReminderBloc>().add(AddReminder(newReminder));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body:
          _medicines.isEmpty
              ? const Center(child: Text("No medicines in inventory. Add a medicine first."))
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
                        hint: const Text('Select a Medicine'),
                        items:
                            _medicines.map((Medicine medicine) {
                              return DropdownMenuItem<Medicine>(value: medicine, child: Text(medicine.name));
                            }).toList(),
                        onChanged: (Medicine? newValue) {
                          setState(() {
                            _selectedMedicine = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a medicine' : null,
                        decoration: const InputDecoration(labelText: 'Medicine', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),

                      // Time Picker
                      ListTile(
                        title: const Text('Reminder Time'),
                        subtitle: Text(_selectedTime?.format(context) ?? 'Not set'),
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
                              label: Text(day.substring(0, 3)),
                              selected: _selectedDays.contains(day),
                              onSelected:
                                  (_selectedDays.contains('Everyday'))
                                      ? null
                                      : (selected) {
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
                        child: ElevatedButton(onPressed: _saveReminder, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Save Reminder')),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
