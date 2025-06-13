import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/medicine_inventory/medicine_inventory_bloc.dart';
import '../blocs/medicine_inventory/medicine_inventory_event.dart';
import '../blocs/medicine_inventory/medicine_inventory_state.dart';
import '../models/medicine.dart';

class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;
  const EditMedicineScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  _EditMedicineScreenState createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _image;

  late TextEditingController _nameController;
  late TextEditingController _strengthController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryController;
  late TextEditingController _dosageController;
  late TextEditingController _usageController;
  late TextEditingController _sideEffectsController;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _strengthController = TextEditingController(text: widget.medicine.strength);
    _quantityController = TextEditingController(text: widget.medicine.quantity.toString());
    _expiryDate = widget.medicine.expiryDate;
    _expiryController = TextEditingController(text: DateFormat.yMMMd().format(_expiryDate!));
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _usageController = TextEditingController(text: widget.medicine.usage);
    _sideEffectsController = TextEditingController(text: widget.medicine.sideEffects);
    if (widget.medicine.imagePath != null) {
      _image = File(widget.medicine.imagePath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _strengthController.dispose();
    _quantityController.dispose();
    _expiryController.dispose();
    _dosageController.dispose();
    _usageController.dispose();
    _sideEffectsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
        _expiryController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateMedicine() {
    if (_formKey.currentState!.validate() && _expiryDate != null) {
      final updatedMedicine = Medicine(
        id: widget.medicine.id,
        name: _nameController.text,
        strength: _strengthController.text,
        quantity: int.parse(_quantityController.text),
        expiryDate: _expiryDate!,
        dosage: _dosageController.text,
        usage: _usageController.text,
        sideEffects: _sideEffectsController.text,
        imagePath: _image?.path,
      );

      context.read<MedicineInventoryBloc>().add(UpdateMedicine(updatedMedicine));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedicineInventoryBloc, MedicineInventoryState>(
      listener: (context, state) {
        if (state is MedicineInventoryActionSuccess) {
          Navigator.pop(context);
        } else if (state is MedicineInventoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Medicine'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: _showPicker,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(_image!,
                                fit: BoxFit.cover, width: double.infinity),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 50, color: Colors.grey[600]),
                              const SizedBox(height: 10),
                              Text('Tap to change medicine image',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[600])),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Medicine Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _strengthController,
                  decoration:
                      const InputDecoration(labelText: 'Strength (e.g., 500mg)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medicine strength';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectExpiryDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select expiry date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(labelText: 'Dosage Information'),
                  maxLines: null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _usageController,
                  decoration: const InputDecoration(labelText: 'Usage Information'),
                  maxLines: null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _sideEffectsController,
                  decoration: const InputDecoration(labelText: 'Side Effects'),
                  maxLines: null,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _updateMedicine,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 