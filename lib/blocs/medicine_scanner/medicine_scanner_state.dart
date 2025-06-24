import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class MedicineScannerState extends Equatable {
  const MedicineScannerState();

  @override
  List<Object?> get props => [];
}

class MedicineScannerInitial extends MedicineScannerState {}

class MedicineScannerImagePicked extends MedicineScannerState {
  final XFile image;

  const MedicineScannerImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

class MedicineScannerLoading extends MedicineScannerState {
  final XFile image; // Keep the image to display while loading
  const MedicineScannerLoading(this.image);

  @override
  List<Object?> get props => [image];
}

class MedicineScannerSuccess extends MedicineScannerState {
  final XFile image; // Keep the image to display with results
  final String medicineInfo; // This will hold the response from Ollama

  const MedicineScannerSuccess(this.image, this.medicineInfo);

  @override
  List<Object?> get props => [image, medicineInfo];
}

class MedicineScannerFailure extends MedicineScannerState {
  final XFile? image; // Optionally keep the image
  final String error;

  const MedicineScannerFailure(this.error, {this.image});

  @override
  List<Object?> get props => [error, image];
}
