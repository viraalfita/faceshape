import '../models/face_shape_result.dart';

class FaceShapeHelper {
  static FaceShapeResult buildResult(String shape) {
    final normalized = shape.toUpperCase().trim();
    return FaceShapeResult(
      shape: normalized,
      description: getDescription(normalized),
      recommendations: getRecommendations(normalized),
    );
  }

  static String getDescription(String shape) {
    final shapeUpper = shape.toUpperCase().trim();

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
        return 'Bentuk wajah Anda adalah $shapeUpper. Konsultasikan dengan stylist untuk rekomendasi terbaik.';
    }
  }

  static List<HairstyleRecommendation> getRecommendations(String shape) {
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
                'Konsultasikan dengan stylist profesional untuk rekomendasi terbaik sesuai bentuk wajah $shapeUpper Anda',
            imageUrl:
                'https://static-beautyhigh.stylecaster.com/2015/03/getting-haircut.jpg',
            gender: 'Unisex',
          ),
        ];
  }
}
