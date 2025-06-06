import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ollama_dart/ollama_dart.dart';

import 'medicine_scanner_event.dart';
import 'medicine_scanner_state.dart';

class MedicineScannerBloc extends Bloc<MedicineScannerEvent, MedicineScannerState> {
  final OllamaClient ollama;

  MedicineScannerBloc({required this.ollama}) : super(MedicineScannerInitial()) {
    on<ScanMedicineEvent>(_onScanMedicine);
    on<ClearScanEvent>(_onClearScan);
  }

  Future<void> _onScanMedicine(ScanMedicineEvent event, Emitter<MedicineScannerState> emit) async {
    emit(MedicineScannerLoading(event.image));
    try {
      final imageBytes = await event.image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final request = GenerateCompletionRequest(
        model: 'gemma3:4b-it-qat', // As per user: "Gemma 3 4B model"
        prompt:
            'This is an image of a medicine. Identify the medicine and provide detailed information about it, including its uses, dosage, side effects, and any other relevant warnings or precautions.',
        images: [base64Image],
        // stream: false, // Default for generateCompletion is non-streaming
      );

      final ollamaResponse = await ollama.generateCompletion(request: request);

      if (ollamaResponse.response != null && ollamaResponse.response!.isNotEmpty) {
        emit(MedicineScannerSuccess(event.image, ollamaResponse.response!));
      } else {
        // If response is null or empty, but no explicit error from client, consider it a failure.
        // We could also check ollamaResponse.done and other fields if needed.
        emit(MedicineScannerFailure('Failed to get a valid response from Ollama. The response was empty.', image: event.image));
      }
    } catch (e) {
      // This will catch errors from image reading, OllamaClient communication, etc.
      emit(MedicineScannerFailure('Error processing image: ${e.toString()}', image: event.image));
    }
  }

  void _onClearScan(ClearScanEvent event, Emitter<MedicineScannerState> emit) {
    emit(MedicineScannerInitial());
  }
}
