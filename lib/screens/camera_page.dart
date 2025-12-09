import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      if (status.isGranted || status.isLimited) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Izin galeri diperlukan. Buka pengaturan untuk mengaktifkan.'),
              action: SnackBarAction(
                label: 'Pengaturan',
                onPressed: () => openAppSettings(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return false;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin galeri diperlukan untuk melanjutkan.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return false;
      
    } else if (Platform.isIOS) {
      var status = await Permission.photos.status;
      
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }
      
      if (status.isGranted || status.isLimited) {
        return true;
      }
      
      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Izin galeri diperlukan. Buka pengaturan untuk mengaktifkan.'),
              action: SnackBarAction(
                label: 'Pengaturan',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return false;
      }
      
      return false;
    }
    
    return false;
  }

  Future<String?> _compressAndSaveImage(String imagePath) async {
    try {
      final file = File(imagePath);
      final fileSize = await file.length();
      
      if (fileSize < 500000) {
        return imagePath;
      }
      
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (result != null) {
        final compressedSize = await result.length();
        final savedPercent = ((fileSize - compressedSize) / fileSize * 100).toStringAsFixed(1);
        debugPrint('Compressed: ${fileSize ~/ 1024}KB -> ${compressedSize ~/ 1024}KB ($savedPercent% saved)');
        return result.path;
      }
      
      return imagePath;
    } catch (e) {
      debugPrint('Compression error: $e');
      return imagePath;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isProcessing) return;

    final hasPermission = source == ImageSource.camera
        ? await _ensureCameraPermission()
        : await _ensureGalleryPermission();
    
    if (!hasPermission) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final photo = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) {
        debugPrint('⚠️ [Picker] User membatalkan');
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
        return;
      }

      _lastCapturedPath = photo.path;

      if (!mounted) return;

      final compressedPath = await _compressAndSaveImage(photo.path);
      final finalPath = compressedPath ?? photo.path;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              margin: EdgeInsets.all(32),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Menganalisis wajah...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Proses memakan waktu 10-30 detik',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Mohon tunggu...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final provider = Provider.of<FaceShapeProvider>(context, listen: false);
      
      try {
        await provider.analyzeFace(finalPath);
        
        if (!mounted) return;
        
        Navigator.of(context).pop();

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
      } catch (e) {
        debugPrint('Error during analysis: $e');
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
