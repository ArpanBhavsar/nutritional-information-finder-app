import 'package:equatable/equatable.dart';
import '../../models/medicine.dart';

abstract class MedicineInventoryEvent extends Equatable {
  const MedicineInventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadMedicines extends MedicineInventoryEvent {}

class AddMedicine extends MedicineInventoryEvent {
  final Medicine medicine;

  const AddMedicine(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class UpdateMedicine extends MedicineInventoryEvent {
  final Medicine medicine;

  const UpdateMedicine(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class DeleteMedicine extends MedicineInventoryEvent {
  final String id;

  const DeleteMedicine(this.id);

  @override
  List<Object> get props => [id];
}

class LoadMedicineById extends MedicineInventoryEvent {
  final String id;

  const LoadMedicineById(this.id);

  @override
  List<Object> get props => [id];
} 