import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/database_helper.dart';
import 'medicine_database_event.dart';
import 'medicine_database_state.dart';

class MedicineDatabaseBloc extends Bloc<MedicineDatabaseEvent, MedicineDatabaseState> {
  final DatabaseHelper _databaseHelper;

  MedicineDatabaseBloc(this._databaseHelper) : super(MedicineDatabaseInitial()) {
    on<InitializeDatabaseEvent>(_onInitializeDatabase);
    on<AddMedicineToDbEvent>(_onAddMedicineToDb);
    on<LoadMedicinesFromDbEvent>(_onLoadMedicinesFromDb);
  }

  Future<void> _onInitializeDatabase(
    InitializeDatabaseEvent event,
    Emitter<MedicineDatabaseState> emit,
  ) async {
    emit(MedicineDatabaseLoading());
    try {
      await _databaseHelper.database; // Ensures DB is created if not already
      emit(MedicineDatabaseSuccess(message: 'Database Initialized'));
      add(LoadMedicinesFromDbEvent()); // Load medicines after initialization
    } catch (e) {
      emit(MedicineDatabaseFailure(e.toString()));
    }
  }

  Future<void> _onAddMedicineToDb(
    AddMedicineToDbEvent event,
    Emitter<MedicineDatabaseState> emit,
  ) async {
    emit(MedicineDatabaseLoading());
    try {
      await _databaseHelper.addMedicine(event.medicine);
      emit(MedicineDatabaseSuccess(message: 'Medicine Added Successfully')); // More specific message
      add(LoadMedicinesFromDbEvent()); // Refresh the list
    } catch (e) {
      emit(MedicineDatabaseFailure(e.toString()));
    }
  }

  Future<void> _onLoadMedicinesFromDb(
    LoadMedicinesFromDbEvent event,
    Emitter<MedicineDatabaseState> emit,
  ) async {
    emit(MedicineDatabaseLoading());
    try {
      final medicines = await _databaseHelper.getMedicines();
      emit(MedicineDatabaseLoaded(medicines));
    } catch (e) {
      emit(MedicineDatabaseFailure(e.toString()));
    }
  }
}
