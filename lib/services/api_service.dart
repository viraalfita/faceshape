import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/face_shape_result.dart';

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
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
        ),
      );

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

      String shape = jsonResponse['final_prediction'] ?? 
                     jsonResponse['face_shape'] ?? 
                     jsonResponse['shape'] ?? 
                     'Unknown';
      
      debugPrint('Face shape detected: $shape');
      
      String description = _getDescription(shape);
      List<HairstyleRecommendation> recommendations = _getRecommendations(shape);
      
      return FaceShapeResult(
        shape: shape.toUpperCase(),
        description: description,
        recommendations: recommendations,
      );
    } catch (e) {
      debugPrint('Error during face analysis: $e');
      throw Exception('Gagal menganalisis wajah: $e');
    }
  }

  String _getDescription(String shape) {
    final shapeUpper = shape.toUpperCase().trim();
    debugPrint('Getting description for shape: $shapeUpper');
    
    switch (shapeUpper) {
      case 'OVAL':
        return 'Wajah oval memiliki proporsi seimbang dengan dagu yang sedikit meruncing. Hampir semua gaya rambut cocok untuk bentuk wajah ini.';
      case 'ROUND':
        return 'Wajah bulat memiliki pipi yang penuh dan garis rahang yang lembut. Gaya rambut yang menambah panjang akan sangat cocok.';
      case 'SQUARE':
        return 'Wajah kotak memiliki rahang yang kuat dan dahi lebar. Gaya rambut yang melembut sudut wajah sangat direkomendasikan.';
      case 'HEART':
        return 'Wajah hati memiliki dahi lebar dan dagu meruncing. Gaya rambut yang menyeimbangkan proporsi akan sangat cocok.';
      case 'OBLONG':
        return 'Wajah oblong atau panjang memiliki panjang yang lebih besar dari lebar. Gaya rambut yang menambah lebar akan sangat cocok.';
      default:
        debugPrint('Warning: Unknown shape "$shapeUpper", using default description');
        return 'Bentuk wajah Anda adalah $shape. Konsultasikan dengan stylist untuk rekomendasi terbaik.';
    }
  }

  List<HairstyleRecommendation> _getRecommendations(String shape) {
    final shapeUpper = shape.toUpperCase().trim();
    
    switch (shapeUpper) {
      case 'OVAL':
        return [
          HairstyleRecommendation(
            name: 'Long Layered Cut',
            description: 'Memberikan volume dan dimensi pada wajah oval',
            imageUrl: 'https://thechicsavvy.com/wp-content/uploads/2025/03/Layered-hairstyles1.webp',
          ),
          HairstyleRecommendation(
            name: 'Side Swept Bangs',
            description: 'Menambah karakter dengan poni samping',
            imageUrl: 'https://i0.wp.com/therighthairstyles.com/wp-content/uploads/2014/07/20-medium-razored-haircut-with-side-bangs.jpg?w=500&ssl=1',
          ),
          HairstyleRecommendation(
            name: 'Bob Cut',
            description: 'Potongan klasik yang selalu cocok',
            imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/bob-haircuts-side-bangs-665a123b364ca.jpg?crop=1xw:0.833740234375xh;center,top',
          ),
        ];
      case 'ROUND':
        return [
          HairstyleRecommendation(
            name: 'Long Straight Hair',
            description: 'Menambah panjang dan menyeimbangkan wajah bulat',
            imageUrl: 'https://example.com/round1.jpg',
          ),
          HairstyleRecommendation(
            name: 'Textured Lob',
            description: 'Menciptakan ilusi wajah lebih panjang',
            imageUrl: 'https://example.com/round2.jpg',
          ),
        ];
      case 'SQUARE':
        return [
          HairstyleRecommendation(
            name: 'Soft Waves',
            description: 'Melembut sudut wajah kotak',
            imageUrl: 'https://example.com/square1.jpg',
          ),
          HairstyleRecommendation(
            name: 'Long Layers',
            description: 'Menambah kelembutan pada rahang',
            imageUrl: 'https://example.com/square2.jpg',
          ),
        ];
      case 'OBLONG':
        return [
          HairstyleRecommendation(
            name: 'Chin Length Bob',
            description: 'Menambah lebar pada wajah oblong',
            imageUrl: 'https://example.com/oblong1.jpg',
          ),
          HairstyleRecommendation(
            name: 'Layered Waves',
            description: 'Menciptakan volume di samping',
            imageUrl: 'https://example.com/oblong2.jpg',
          ),
        ];
      case 'HEART':
        return [
          HairstyleRecommendation(
            name: 'Chin Length Cut',
            description: 'Menyeimbangkan dagu yang meruncing',
            imageUrl: 'https://example.com/heart1.jpg',
          ),
          HairstyleRecommendation(
            name: 'Side Part Waves',
            description: 'Mengurangi lebar dahi',
            imageUrl: 'https://example.com/heart2.jpg',
          ),
        ];
      default:
        debugPrint('Warning: No specific recommendations for shape "$shapeUpper"');
        return [
          HairstyleRecommendation(
            name: 'Konsultasi Stylist',
            description: 'Konsultasikan dengan stylist profesional untuk rekomendasi terbaik sesuai bentuk wajah $shape Anda',
            imageUrl: 'https://example.com/default.jpg',
          ),
        ];
    }
  }
}
