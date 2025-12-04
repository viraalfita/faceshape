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
      _error = 'Wajah tidak terdeteksi';
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
