import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/face_shape_provider.dart';
import 'error_page.dart';
import 'result_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  String? _lastCapturedPath;

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    }

    if (!mounted) return false;

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin kamera ditolak permanen. Buka pengaturan untuk mengaktifkan.'),
        ),
      );
      await openAppSettings();
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Izin kamera diperlukan untuk melanjutkan.'),
      ),
    );
    return false;
  }

  Future<bool> _ensureGalleryPermission() async {
    final status = await Permission.photos.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin galeri ditolak permanen. Buka pengaturan untuk mengaktifkan.'),
          ),
        );
      }
      await openAppSettings();
      return false;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin galeri diperlukan untuk melanjutkan.'),
        ),
      );
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    final hasPermission = source == ImageSource.camera
        ? await _ensureCameraPermission()
        : await _ensureGalleryPermission();
    if (!hasPermission) return;

    setState(() {
      _isProcessing = true;
    });

    final photo = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );

    if (photo == null) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      return;
    }

    _lastCapturedPath = photo.path;

    if (!mounted) return;

    final provider = Provider.of<FaceShapeProvider>(context, listen: false);
    await provider.analyzeFace(photo.path);

    if (!mounted) return;

    if (provider.error != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ErrorPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultPage()),
      );
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      body: Stack(
        children: [
          // Camera view placeholder
          Container(
            color: const Color(0xFF2D3142),
            child: _lastCapturedPath == null
                ? null
                : Center(
              child: Image.file(
                File(_lastCapturedPath!),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Face outline
          Center(
            child: Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.photo_library, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFB24AE5), Color(0xFFE94CA1)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFB24AE5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Menganalisis wajah...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
