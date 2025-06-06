import 'package:flutter/foundation.dart';
import '../../models/medicine.dart';

@immutable
abstract class MedicineDatabaseState {}

class MedicineDatabaseInitial extends MedicineDatabaseState {}

class MedicineDatabaseLoading extends MedicineDatabaseState {}

class MedicineDatabaseLoaded extends MedicineDatabaseState {
  final List<Medicine> medicines;

  MedicineDatabaseLoaded(this.medicines);
}

class MedicineDatabaseSuccess extends MedicineDatabaseState {
  final String? message; // Optional success message
  MedicineDatabaseSuccess({this.message});
}

class MedicineDatabaseFailure extends MedicineDatabaseState {
  final String error;

  MedicineDatabaseFailure(this.error);
}
