import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollama_dart/ollama_dart.dart';

import '../blocs/medicine_scanner/medicine_scanner_bloc.dart';
import '../blocs/medicine_scanner/medicine_scanner_event.dart';
import '../blocs/medicine_scanner/medicine_scanner_state.dart';

class MedicineScannerScreen extends StatefulWidget {
  const MedicineScannerScreen({Key? key}) : super(key: key);

  @override
  _MedicineScannerScreenState createState() => _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends State<MedicineScannerScreen> {
  final picker = ImagePicker();
  late final OllamaClient _ollamaClient;
  late final MedicineScannerBloc _medicineScannerBloc;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _ollamaClient = OllamaClient(baseUrl: 'http://10.0.2.2:11434/api');
    _medicineScannerBloc = MedicineScannerBloc(ollama: _ollamaClient);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 0 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 0 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  void dispose() {
    _medicineScannerBloc.close();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _medicineScannerBloc.add(ScanMedicineEvent(File(pickedFile.path)));
    } else {
      print('No image selected.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No image selected.')));
      }
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _medicineScannerBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medicine Scanner'),
          actions: [
            BlocBuilder<MedicineScannerBloc, MedicineScannerState>(
              builder: (context, state) {
                if (state is! MedicineScannerInitial && state is! MedicineScannerLoading) {
                  return IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Scan new image',
                    onPressed: () {
                      context.read<MedicineScannerBloc>().add(ClearScanEvent());
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<MedicineScannerBloc, MedicineScannerState>(
          listener: (context, state) {
            if (state is MedicineScannerFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red));
            } else if (state is MedicineScannerSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analysis Complete!'), backgroundColor: Colors.green));
            }
          },
          builder: (context, state) {
            File? currentImage;
            if (state is MedicineScannerImagePicked) currentImage = state.image;
            if (state is MedicineScannerLoading) currentImage = state.image;
            if (state is MedicineScannerSuccess) currentImage = state.image;
            if (state is MedicineScannerFailure && state.image != null) currentImage = state.image!;

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child:
                        currentImage != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(12.0), child: Image.file(currentImage, fit: BoxFit.contain, height: 300))
                            : Container(
                              height: 200,
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12.0)),
                              child: const Center(child: Text('No image selected.', style: TextStyle(fontSize: 16))),
                            ),
                  ),
                  const SizedBox(height: 20),
                  if (state is MedicineScannerLoading) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 10),
                    const Text('Analyzing medicine...', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  ] else if (state is MedicineScannerSuccess) ...[
                    const Text('Medicine Information:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: state.medicineInfo,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(p: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
                    ),
                  ] else if (state is MedicineScannerFailure) ...[
                    Text('Failed to analyze. ${state.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  ] else if (state is MedicineScannerInitial || state is MedicineScannerImagePicked) ...[
                    const Text('Pick an image to start analysis.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  ],
                ],
              ),
            );
          },
        ),
        floatingActionButton: BlocBuilder<MedicineScannerBloc, MedicineScannerState>(
          builder: (context, state) {
            if (state is MedicineScannerSuccess || state is MedicineScannerFailure || state is MedicineScannerInitial || state is MedicineScannerImagePicked) {
              if (_isScrolled) {
                return FloatingActionButton(onPressed: _showPicker, tooltip: 'Scan Medicine', child: const Icon(Icons.camera_alt));
              } else {
                String labelText = (state is MedicineScannerSuccess || state is MedicineScannerFailure || state is MedicineScannerImagePicked) ? 'Scan Another Medicine' : 'Scan Medicine';

                return FloatingActionButton.extended(onPressed: _showPicker, label: Text(labelText), icon: const Icon(Icons.camera_alt));
              }
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButtonLocation: _isScrolled ? FloatingActionButtonLocation.endFloat : FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
