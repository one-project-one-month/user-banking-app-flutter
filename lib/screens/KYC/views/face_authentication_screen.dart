import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FaceAuthenticationScreen extends StatefulWidget {
  const FaceAuthenticationScreen({super.key});

  @override
  _FaceAuthenticationScreenState createState() =>
      _FaceAuthenticationScreenState();
}

class _FaceAuthenticationScreenState extends State<FaceAuthenticationScreen> {
  CameraController? _cameraController;
  Timer? _frameTimer;
  String _currentInstruction = 'Press camera button to start';
  bool _isAuthenticating = false;
  bool _cameraInitialized = false;
  String? _errorMessage;
  String _detectedPose = 'Unknown';
  int _currentStep = 0;
  int _totalSteps = 4;

  static const String _serverIp = 'http://10.170.47.23:8000';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on device';
        });
        return;
      }

      // Use front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera initialization failed: $e';
      });
    }
  }

  Future<void> _startAuthentication() async {
    try {
      // Reset on server
      final response = await http.post(Uri.parse('$_serverIp/api/face/reset'));

      if (response.statusCode != 200) {
        throw Exception('Failed to reset: ${response.statusCode}');
      }

      setState(() {
        _isAuthenticating = true;
        _currentInstruction = 'Starting authentication...';
        _currentStep = 0;
      });

      // Start sending frames
      _startFrameCapture();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _startFrameCapture() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (_isAuthenticating && _cameraController != null) {
        try {
          final image = await _cameraController!.takePicture();
          await _sendFrameForAnalysis(image);
        } catch (e) {
          print('Frame capture error: $e');
        }
      }
    });
  }

  Future<void> _sendFrameForAnalysis(XFile image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_serverIp/api/face/analyze'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);

        setState(() {
          _detectedPose = data['detected_pose'] ?? 'Unknown';
          _currentStep = data['current_step'] ?? 0;
          _totalSteps = data['total_steps'] ?? 4;
          _currentInstruction = 'Please: ${data['current_pose_required']}';

          if (data['login_finished'] == true) {
            _isAuthenticating = false;
            _frameTimer?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Authentication successful!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Frame analysis error: $e');
    }
  }

  Future<void> _stopAuthentication() async {
    setState(() {
      _isAuthenticating = false;
      _currentInstruction = 'Press camera button to start';
    });
    _frameTimer?.cancel();
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Face Authentication',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _cameraInitialized = false;
                      });
                      _initializeCamera();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (!_cameraInitialized)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Initializing camera...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          else
            Center(child: CameraPreview(_cameraController!)),
          if (_cameraInitialized)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(160),
                      border: Border.all(
                        color: _isAuthenticating ? Colors.green : Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _currentInstruction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_isAuthenticating) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Progress: $_currentStep/$_totalSteps',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detected: $_detectedPose',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_cameraInitialized)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _isAuthenticating ? _stopAuthentication : null,
                    ),
                    FloatingActionButton.large(
                      backgroundColor: const Color(0xFF0A3D62),
                      elevation: 8,
                      child: Icon(
                        _isAuthenticating ? Icons.stop : Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        if (_isAuthenticating) {
                          _stopAuthentication();
                        } else {
                          _startAuthentication();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Instructions'),
                                content: const Text(
                                  'Follow the sequence:\n\n'
                                  '1. Look Left\n'
                                  '2. Look Right\n'
                                  '3. Look Up\n'
                                  '4. Smile\n\n'
                                  'Hold each pose for 1 second.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Got it'),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
