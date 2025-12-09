import 'package:flutter/foundation.dart';

import '../models/face_shape_result.dart';
import '../services/api_service.dart';

class FaceShapeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  FaceShapeResult? _result;
  bool _isLoading = false;
  String? _error;
  String? _imagePath;

  FaceShapeResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get imagePath => _imagePath;

  Future<void> analyzeFace(String imagePath) async {
    _isLoading = true;
    _error = null;
    _imagePath = imagePath;
    notifyListeners();

    try {
      _result = await _apiService.analyzeFace(imagePath);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Face analysis failed: $e');
      
      // Parse error message untuk memberikan feedback yang lebih baik
      String errorMessage = e.toString();
      
      if (errorMessage.contains('No face detected')) {
        _error = 'Wajah tidak terdeteksi. Pastikan foto wajah Anda jelas dan menghadap kamera.';
      } else if (errorMessage.contains('timeout')) {
        _error = 'Koneksi timeout. Periksa koneksi internet Anda.';
      } else if (errorMessage.contains('Server error')) {
        _error = 'Server sedang sibuk. Coba lagi dalam beberapa saat.';
      } else if (errorMessage.contains('File tidak ditemukan')) {
        _error = 'File gambar tidak ditemukan.';
      } else {
        _error = 'Gagal menganalisis wajah. Silakan coba lagi.';
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _result = null;
    _error = null;
    _imagePath = null;
    _isLoading = false;
    notifyListeners();
  }
}
