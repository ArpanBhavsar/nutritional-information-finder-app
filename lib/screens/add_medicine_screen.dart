import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../models/medicine.dart';
import '../blocs/medicine_database/medicine_database_bloc.dart';
import '../blocs/medicine_database/medicine_database_event.dart';
import '../blocs/medicine_database/medicine_database_state.dart';
import '../utils/database_helper.dart';

class AddMedicineScreen extends StatelessWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicineDatabaseBloc(DatabaseHelper.instance),
      child: const _AddMedicineForm(),
    );
  }
}

class _AddMedicineForm extends StatefulWidget {
  const _AddMedicineForm({Key? key}) : super(key: key);

  @override
  _AddMedicineFormState createState() => _AddMedicineFormState();
}

class _AddMedicineFormState extends State<_AddMedicineForm> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? _pickedImage;
  String _medicineName = '';
  String _expiryDate = '';
  String _strength = '';
  int _quantity = 0;
  String _dosageInformation = '';
  String _usageInformation = '';
  String _sideEffects = '';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  void _showPicker(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Medicine'),
      ),
      body: BlocListener<MedicineDatabaseBloc, MedicineDatabaseState>(
        listener: (context, state) {
          if (state is MedicineDatabaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Medicine added successfully!'), backgroundColor: Colors.green),
            );
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true); // Pop with a success flag to indicate refresh needed
              }
            });
          } else if (state is MedicineDatabaseFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add medicine: ${state.error}'), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Center(
                  child: GestureDetector(
                    onTap: () => _showPicker(context),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
                      child: _pickedImage == null
                          ? Icon(
                              Icons.add_a_photo_outlined,
                              color: Colors.grey[700],
                              size: 40,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Medicine Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _medicineName = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    try {
                      DateTime.parse(value);
                    } catch (e) {
                      return 'Invalid date format (YYYY-MM-DD)';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _expiryDate = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Strength (e.g., 500mg)'),
                  onSaved: (value) {
                    _strength = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _quantity = int.tryParse(value ?? '0') ?? 0;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Dosage Information'),
                  onSaved: (value) {
                    _dosageInformation = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Usage Information'),
                  onSaved: (value) {
                    _usageInformation = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Side Effects'),
                  onSaved: (value) {
                    _sideEffects = value ?? '';
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: BlocBuilder<MedicineDatabaseBloc, MedicineDatabaseState>(
                    builder: (context, state) {
                      if (state is MedicineDatabaseLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final newMedicine = Medicine(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              name: _medicineName,
                              imagePath: _pickedImage?.path ?? '',
                              strength: _strength,
                              quantity: _quantity,
                              expiryDate: DateTime.parse(_expiryDate),
                              dosageInformation: _dosageInformation.isNotEmpty ? _dosageInformation : null,
                              usageInformation: _usageInformation.isNotEmpty ? _usageInformation : null,
                              sideEffects: _sideEffects.isNotEmpty ? _sideEffects : null,
                            );
                            context.read<MedicineDatabaseBloc>().add(AddMedicineToDbEvent(newMedicine));
                          }
                        },
                        child: const Text('Add Medicine to Database'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
