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

      String description = _getDescription(shape);
      List<HairstyleRecommendation> recommendations = _getRecommendations(
        shape,
      );

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
        debugPrint(
          'Warning: Unknown shape "$shapeUpper", using default description',
        );
        return 'Bentuk wajah Anda adalah $shape. Konsultasikan dengan stylist untuk rekomendasi terbaik.';
    }
  }

  List<HairstyleRecommendation> _getRecommendations(String shape) {
    final shapeUpper = shape.toUpperCase().trim();

    final recommendations = {
      'OVAL': [
        HairstyleRecommendation(
          name: 'Long Layered Cut',
          description: 'Memberikan volume dan dimensi pada wajah oval',
          imageUrl:
              'https://thechicsavvy.com/wp-content/uploads/2025/03/Layered-hairstyles1.webp',
          gender: 'Wanita',
        ),
        HairstyleRecommendation(
          name: 'Classic Pompadour',
          description:
              'Meninggikan bagian depan untuk menonjolkan struktur wajah oval',
          imageUrl:
              'https://cdn.shopify.com/s/files/1/0434/4749/files/IMG_5708-01-01_grande.jpg?v=1567588961',
          gender: 'Pria',
        ),
      ],
      'ROUND': [
        HairstyleRecommendation(
          name: 'Long Straight Hair',
          description: 'Menambah panjang dan menyeimbangkan wajah bulat',
          imageUrl:
              'https://content.latest-hairstyles.com/wp-content/uploads/long-and-dark-straight-hairstyle-with-middle-parting.jpg',
          gender: 'Wanita',
        ),
        HairstyleRecommendation(
          name: 'Faux Hawk',
          description: 'Memberikan tinggi untuk memanjangkan wajah bulat',
          imageUrl:
              'https://cdn.shopify.com/s/files/1/0029/0868/4397/files/Faux-Hawk-Fade.webp?v=1754387960',
          gender: 'Pria',
        ),
      ],
      'SQUARE': [
        HairstyleRecommendation(
          name: 'Soft Waves',
          description: 'Melembutkan sudut wajah kotak',
          imageUrl:
              'https://www.fabmood.com/inspiration/wp-content/uploads/2025/02/9001425401685741.jpg',
          gender: 'Wanita',
        ),
        HairstyleRecommendation(
          name: 'Tapered Sides with Volume Top',
          description: 'Memberikan keseimbangan pada rahang yang kuat',
          imageUrl:
              'https://www.menshairstylestoday.com/wp-content/uploads/2023/06/Crop-Top-with-High-Taper.jpg.webp',
          gender: 'Pria',
        ),
      ],
      'OBLONG': [
        HairstyleRecommendation(
          name: 'Chin Length Bob',
          description: 'Menambah lebar pada wajah oblong',
          imageUrl:
              'https://www.instyle.com/thmb/RKBmUgYfuz4xRyRoC9ORvMIH38g=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-1724970358-e2357e7f7cf74fad98736cac7eab5000.jpg',
          gender: 'Wanita',
        ),
        HairstyleRecommendation(
          name: 'Side Part with Volume',
          description: 'Menambah lebar pada sisi wajah',
          imageUrl:
              'https://i.pinimg.com/736x/00/25/6a/00256afdbc2e341a725e02c3cb4aeaf2.jpg',
          gender: 'Pria',
        ),
      ],
    };

    return recommendations[shapeUpper] ??
        [
          HairstyleRecommendation(
            name: 'Konsultasi Stylist',
            description:
                'Konsultasikan dengan stylist profesional untuk rekomendasi terbaik sesuai bentuk wajah $shape Anda',
            imageUrl:
                'https://static-beautyhigh.stylecaster.com/2015/03/getting-haircut.jpg',
            gender: 'Unisex',
          ),
        ];
  }
}
