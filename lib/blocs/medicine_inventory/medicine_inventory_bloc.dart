import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database_service.dart';
import 'medicine_inventory_event.dart';
import 'medicine_inventory_state.dart';

class MedicineInventoryBloc extends Bloc<MedicineInventoryEvent, MedicineInventoryState> {
  final DatabaseService _databaseService;

  MedicineInventoryBloc()
      : _databaseService = DatabaseService(),
        super(MedicineInventoryInitial()) {
    on<LoadMedicines>(_onLoadMedicines);
    on<AddMedicine>(_onAddMedicine);
    on<UpdateMedicine>(_onUpdateMedicine);
    on<DeleteMedicine>(_onDeleteMedicine);
    on<LoadMedicineById>(_onLoadMedicineById);
  }

  Future<void> _onLoadMedicines(LoadMedicines event, Emitter<MedicineInventoryState> emit) async {
    emit(MedicineInventoryLoading());
    try {
      final medicines = await _databaseService.getMedicines();
      emit(MedicineInventoryLoaded(medicines));
    } catch (e) {
      emit(MedicineInventoryError(e.toString()));
    }
  }

  Future<void> _onLoadMedicineById(LoadMedicineById event, Emitter<MedicineInventoryState> emit) async {
    emit(MedicineInventoryLoading());
    try {
      final medicine = await _databaseService.getMedicineById(event.id);
      if (medicine != null) {
        emit(MedicineLoaded(medicine));
      } else {
        emit(const MedicineInventoryError('Medicine not found'));
      }
    } catch (e) {
      emit(MedicineInventoryError(e.toString()));
    }
  }

  Future<void> _onAddMedicine(AddMedicine event, Emitter<MedicineInventoryState> emit) async {
    try {
      await _databaseService.insertMedicine(event.medicine);
      emit(MedicineInventoryActionSuccess());
    } catch (e) {
      emit(MedicineInventoryError(e.toString()));
    }
  }

  Future<void> _onUpdateMedicine(UpdateMedicine event, Emitter<MedicineInventoryState> emit) async {
    try {
      await _databaseService.updateMedicine(event.medicine);
      emit(MedicineInventoryActionSuccess());
      add(LoadMedicines());
    } catch (e) {
      emit(MedicineInventoryError(e.toString()));
    }
  }

  Future<void> _onDeleteMedicine(DeleteMedicine event, Emitter<MedicineInventoryState> emit) async {
    try {
      await _databaseService.deleteMedicine(event.id);
      add(LoadMedicines());
    } catch (e) {
      emit(MedicineInventoryError(e.toString()));
    }
  }
} 