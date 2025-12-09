import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/face_shape_provider.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FaceShapeProvider>(context);
    final errorMessage = provider.error ?? 'Wajah tidak terdeteksi';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEE2E2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                errorMessage.split('.')[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage.contains('.')
                    ? errorMessage.substring(errorMessage.indexOf('.') + 1).trim()
                    : 'Pastikan foto wajah Anda jelas dan menghadap kamera dengan pencahayaan yang baik.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '💡 Tips:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Pastikan wajah menghadap kamera', style: TextStyle(fontSize: 14)),
                    Text('• Gunakan pencahayaan yang cukup', style: TextStyle(fontSize: 14)),
                    Text('• Hindari foto yang blur', style: TextStyle(fontSize: 14)),
                    Text('• Pastikan koneksi internet stabil', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB24AE5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
