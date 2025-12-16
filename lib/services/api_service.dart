import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/face_shape_result.dart';
import '../utils/face_shape_helper.dart';

class ApiService {
  final String apiUrl = 'https://epilson-raimulabs.hf.space/predict';

  Future<FaceShapeResult> analyzeFace(String imagePath) async {
    try {
      debugPrint('Starting face analysis');
      debugPrint('Image path: $imagePath');

      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan: $imagePath');
      }

      final fileSize = await file.length();
      debugPrint('File size: ${fileSize ~/ 1024} KB');

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      debugPrint('Sending request to server...');

      var response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout - server tidak merespons');
        },
      );

      debugPrint('Response received with status: ${response.statusCode}');

      var responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      var jsonResponse = json.decode(responseBody);

      if (jsonResponse['error'] != null) {
        throw Exception(jsonResponse['error']);
      }

      String shape =
          jsonResponse['final_prediction'] ??
          jsonResponse['face_shape'] ??
          jsonResponse['shape'] ??
          'Unknown';

      debugPrint('Face shape detected: $shape');

      return FaceShapeResult(
        shape: shape.toUpperCase(),
        description: FaceShapeHelper.getDescription(shape),
        recommendations: FaceShapeHelper.getRecommendations(shape),
      );
    } catch (e) {
      debugPrint('Error during face analysis: $e');
      throw Exception('Gagal menganalisis wajah: $e');
    }
  }
}
