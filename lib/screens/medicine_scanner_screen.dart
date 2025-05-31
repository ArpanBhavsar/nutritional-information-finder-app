import 'dart:convert'; // For base64Encode
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/io_client.dart'; // For IOClient to support HttpClient with proxy

class MedicineScannerScreen extends StatefulWidget {
  const MedicineScannerScreen({Key? key}) : super(key: key);

  @override
  _MedicineScannerScreenState createState() => _MedicineScannerScreenState();
}

class _MedicineScannerScreenState extends State<MedicineScannerScreen> {
  File? _image;
  final picker = ImagePicker();
  String? _responseText;
  bool _isLoading = false;

  // --- Configuration for Ollama and Proxy ---
  // TODO: IMPORTANT! Replace with your actual Ollama API base URL.
  // Default Ollama runs on http://localhost:11434
  static const String _ollamaApiBaseUrl = 'http://10.0.2.16:11434';

  // TODO: IMPORTANT! Configure your HTTP proxy if needed.
  // If you don't use a proxy, leave _proxyHost empty or _proxyPort as 0.
  static const String _proxyHost = ''; // e.g., '127.0.0.1' or 'myproxy.example.com'
  static const int _proxyPort = 0;    // e.g., 8888 (use 0 if no proxy or _proxyHost is empty)
  // --- End of Configuration ---


  Future<void> _showImageSourceDialog() async {
    if (_isLoading) return; // Don't show dialog if already processing

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.camera);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    // Reset state for new image processing
    setState(() {
      // _image = null; // Keep previous image visible until new one is picked
      _responseText = null;
      _isLoading = false; // Reset loading state
    });

    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _processImageWithOllama(); // Start processing the new image
      } else {
        print('No image selected.');
        // Optionally, provide feedback if no image was selected
        // setState(() { _responseText = 'Image selection cancelled.'; });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _responseText = 'Error picking image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _processImageWithOllama() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _responseText = null; // Clear previous response
    });

    try {
      final imageBytes = await _image!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // --- HTTP Client Setup with Proxy ---
      final httpClient = HttpClient();
      if (_proxyHost.isNotEmpty && _proxyPort > 0) {
        print('Using proxy: $_proxyHost:$_proxyPort');
        httpClient.findProxy = (uri) {
          return "PROXY $_proxyHost:$_proxyPort";
        };
        // Note: For proxies requiring authentication, dart:io/HttpClient has limited direct support.
        // You might need OS-level configuration or specific packages like `socks_proxy`.
      } else {
        print('No explicit proxy configured. Using system settings or direct connection.');
        httpClient.findProxy = HttpClient.findProxyFromEnvironment;
      }

      // Optional: If your Ollama instance (or proxy) uses a self-signed SSL certificate:
      // httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

      final ioClient = IOClient(httpClient);
      // --- End of HTTP Client Setup ---

      final ollamaClient = OllamaClient(
        // baseUrl: _ollamaApiBaseUrl,
        // client: ioClient, // Pass the custom client
      );

      final request = GenerateCompletionRequest(
        model: 'gemma3:4b', // As specified
        prompt:
            'You are a helpful assistant. The user has provided an image. '
            'If the image appears to be of a medicine (pill, packaging, etc.), '
            'identify the medicine name, describe its common uses, and note any distinct visual characteristics. '
            'If the image is not clearly a medicine, state that. '
            'Respond in Markdown format.',
        images: [base64Image],
        // stream: false, // Default is false, ensures full response
      );

      print('Sending request to Ollama...');
      final response = await ollamaClient.generateCompletion(request: request);
      print('Received response from Ollama.');

      setState(() {
        _responseText = response.response;
        _isLoading = false;
      });
    } catch (e) {
      print('Error processing image with Ollama: $e');
      setState(() {
        _responseText = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: _image == null
                    ? Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(child: Text('No image selected.')),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Image.file(
                          _image!,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.image_search),
                label: const Text("Pick Image to Scan"),
                onPressed: _isLoading ? null : _showImageSourceDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Scanning medicine...'),
                    ],
                  ),
                )
              else if (_responseText != null)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Result:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      MarkdownBody(
                        data: _responseText!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_image != null && !_isLoading && _responseText == null)
                 Padding(
                   padding: const EdgeInsets.only(top: 16.0),
                   child: Center(child: Text(
                     'Image selected. Ready for processing or previous scan yielded no text.',
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey[600]),
                   )),
                 ),
            ],
          ),
        ),
      ),
    );
  }
}