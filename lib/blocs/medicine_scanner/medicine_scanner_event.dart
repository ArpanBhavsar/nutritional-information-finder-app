import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class MedicineScannerEvent extends Equatable {
  const MedicineScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScanMedicineEvent extends MedicineScannerEvent {
  final XFile image;
  final bool useApi;

  const ScanMedicineEvent(this.image, {this.useApi = true});

  @override
  List<Object?> get props => [image, useApi];
}

// Event to clear the image and analysis, perhaps for a new scan
class ClearScanEvent extends MedicineScannerEvent {}
