import 'package:equatable/equatable.dart';
import '../../models/medicine.dart';

abstract class MedicineInventoryState extends Equatable {
  const MedicineInventoryState();

  @override
  List<Object> get props => [];
}

class MedicineInventoryInitial extends MedicineInventoryState {}

class MedicineInventoryLoading extends MedicineInventoryState {}

class MedicineInventoryLoaded extends MedicineInventoryState {
  final List<Medicine> medicines;

  const MedicineInventoryLoaded(this.medicines);

  @override
  List<Object> get props => [medicines];
}

class MedicineLoaded extends MedicineInventoryState {
  final Medicine medicine;

  const MedicineLoaded(this.medicine);

  @override
  List<Object> get props => [medicine];
}

class MedicineInventoryActionSuccess extends MedicineInventoryState {}

class MedicineInventoryError extends MedicineInventoryState {
  final String message;

  const MedicineInventoryError(this.message);

  @override
  List<Object> get props => [message];
} 