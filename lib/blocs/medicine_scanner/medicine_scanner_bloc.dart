import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'medicine_scanner_event.dart';
import 'medicine_scanner_state.dart';

class MedicineScannerBloc
    extends Bloc<MedicineScannerEvent, MedicineScannerState> {
  final OllamaClient ollama;
  final SupabaseClient supabase;

  MedicineScannerBloc({required this.ollama, required this.supabase})
    : super(MedicineScannerInitial()) {
    on<ScanMedicineEvent>(_onScanMedicine);
    on<ClearScanEvent>(_onClearScan);
  }

  Future<void> _onScanMedicine(
    ScanMedicineEvent event,
    Emitter<MedicineScannerState> emit,
  ) async {
    emit(MedicineScannerLoading(event.image));
    try {
      final imageBytes = await event.image.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      const prompt =
          'This is an image of a medicine. Identify the medicine and provide detailed information about it, including its uses, dosage, side effects, and any other relevant warnings or precautions.';

      if (event.useApi) {
        final imagePath = event.image.path;
        final imageExtension = p.extension(imagePath).toLowerCase();
        String imageType;

        if (imageExtension == '.jpg' || imageExtension == '.jpeg') {
          imageType = 'image/jpeg';
        } else if (imageExtension == '.png') {
          imageType = 'image/png';
        } else {
          emit(
            MedicineScannerFailure(
              'Unsupported image type: $imageExtension. Only JPEG and PNG are supported.',
              image: event.image,
            ),
          );
          return;
        }

        final res = await supabase.functions.invoke(
          'google-genai-function',
          body: {
            'imageBase64': base64Image,
            'imageType': imageType,
            'userText': prompt,
          },
        );

        final data = res.data;
        String? resultText;

        if (data != null) {
          if (data is String) {
            resultText = data;
          } else if (data is Map) {
            if (data.containsKey('response') && data['response'] is String) {
              resultText = data['response'];
            } else if (data.containsKey('text') && data['text'] is String) {
              resultText = data['text'];
            } else if (data.containsKey('data') && data['data'] is String) {
              resultText = data['data'];
            } else {
              // Fallback for unexpected map structure
              resultText = data.toString();
            }
          }
        }

        if (resultText != null && resultText.isNotEmpty) {
          emit(MedicineScannerSuccess(event.image, resultText));
        } else if (res.status != 200) {
          emit(
            MedicineScannerFailure(
              'Failed to call Supabase function. Status: ${res.status}',
              image: event.image,
            ),
          );
        } else {
          emit(
            MedicineScannerFailure(
              'Failed to get a valid response from the API. The response was empty or in an unexpected format.',
              image: event.image,
            ),
          );
        }
      } else {
        final request = GenerateCompletionRequest(
          model: 'gemma3:4b-it-qat',
          prompt: prompt,
          images: [base64Image],
        );

        final ollamaResponse = await ollama.generateCompletion(
          request: request,
        );

        if (ollamaResponse.response != null &&
            ollamaResponse.response!.isNotEmpty) {
          emit(MedicineScannerSuccess(event.image, ollamaResponse.response!));
        } else {
          emit(
            MedicineScannerFailure(
              'Failed to get a valid response from Ollama. The response was empty.',
              image: event.image,
            ),
          );
        }
      }
    } catch (e) {
      emit(
        MedicineScannerFailure(
          'Error processing image: ${e.toString()}',
          image: event.image,
        ),
      );
    }
  }

  void _onClearScan(ClearScanEvent event, Emitter<MedicineScannerState> emit) {
    emit(MedicineScannerInitial());
  }
}
