import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class MedicineScannerEvent extends Equatable {
  const MedicineScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScanMedicineEvent extends MedicineScannerEvent {
  final File image;

  const ScanMedicineEvent(this.image);

  @override
  List<Object?> get props => [image];
}

// Event to clear the image and analysis, perhaps for a new scan
class ClearScanEvent extends MedicineScannerEvent {}
