import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../providers/face_shape_provider.dart';
import '../providers/history_provider.dart';
import 'guide_page.dart';
import 'error_page.dart';
import 'history_page.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isPicking = false;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera ditolak permanen. Buka pengaturan untuk mengaktifkan.'),
          ),
        );
      }
      await openAppSettings();
      return false;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin kamera diperlukan untuk melanjutkan.'),
        ),
      );
    }
    return false;
  }

  Future<bool> _ensureGalleryPermission() async {
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
            content: const Text('Izin galeri diperlukan. Buka pengaturan.'),
            action: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
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

  Future<File?> _compressAndSaveImage(XFile image) async {
    try {
      final originalFile = File(image.path);
      final originalSize = await originalFile.length();
      
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      final result = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (result == null) {
        debugPrint('Compression failed');
        return null;
      }
      
      final compressedFile = File(result.path);
      final compressedSize = await compressedFile.length();
      final savedPercent = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
      debugPrint('Compressed: ${(originalSize / 1024).toStringAsFixed(0)}KB -> ${(compressedSize / 1024).toStringAsFixed(0)}KB ($savedPercent% saved)');
      
      return compressedFile;
    } catch (e) {
      debugPrint('Compression error: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking || _isAnalyzing) return;

    final hasPermission = source == ImageSource.camera
        ? await _ensureCameraPermission()
        : await _ensureGalleryPermission();
    
    if (!hasPermission) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    final image = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );

    if (image == null) {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
      return;
    }

    final compressedFile = await _compressAndSaveImage(image);
    
    if (compressedFile == null) {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses gambar')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isPicking = false;
        _isAnalyzing = true;
      });
    }

    final provider = Provider.of<FaceShapeProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    await provider.analyzeFace(compressedFile.path);

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    if (provider.error != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ErrorPage()),
      );
    } else {
      if (provider.imagePath != null && provider.result != null) {
        await historyProvider.addHistory(
          imagePath: provider.imagePath!,
          shape: provider.result!.shape,
        );
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResultPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFFB24AE5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kenali Bentuk Wajahmu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan wajahmu untuk mendapatkan\nrekomendasi hairstyle.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3E8FF),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Color(0xFFB24AE5),
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isPicking || _isAnalyzing) ? null : () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB24AE5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ambil Foto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: (_isPicking || _isAnalyzing) ? null : () => _pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB24AE5),
                      side: const BorderSide(color: Color(0xFFB24AE5)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Upload dari Galeri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GuidePage()),
                      );
                    },
                    child: const Text(
                      'Cara penggunaan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFB24AE5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isAnalyzing)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _spinController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinController.value * 6.283,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                const Color(0xFFB24AE5).withOpacity(0.2),
                                const Color(0xFFE94CA1),
                              ],
                              stops: const [0.2, 1],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB24AE5).withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Menganalisis wajah...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
