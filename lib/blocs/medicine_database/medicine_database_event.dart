import 'package:flutter/foundation.dart';
import '../../models/medicine.dart';

@immutable
abstract class MedicineDatabaseEvent {}

class InitializeDatabaseEvent extends MedicineDatabaseEvent {}

class AddMedicineToDbEvent extends MedicineDatabaseEvent {
  final Medicine medicine;

  AddMedicineToDbEvent(this.medicine);
}

class LoadMedicinesFromDbEvent extends MedicineDatabaseEvent {}
