import '../models/face_shape_result.dart';

class ApiService {
  // Dummy API service
  Future<FaceShapeResult> analyzeFace(String imagePath) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));

    // Dummy response
    return FaceShapeResult(
      shape: 'OVAL',
      description:
          'Wajah oval memiliki proporsi seimbang dengan dagu yang sedikit meruncing. Hampir semua gaya rambut cocok untuk bentuk wajah ini.',
      recommendations: [
        HairstyleRecommendation(
          name: 'Long Layered Cut',
          description: 'Memberikan volume dan dimensi pada wajah oval',
          imageUrl:
              'https://thechicsavvy.com/wp-content/uploads/2025/03/Layered-hairstyles1.webp',
        ),
        HairstyleRecommendation(
          name: 'Side Swept Bangs',
          description: 'Menambah karakter dengan poni samping',
          imageUrl:
              'https://i0.wp.com/therighthairstyles.com/wp-content/uploads/2014/07/20-medium-razored-haircut-with-side-bangs.jpg?w=500&ssl=1',
        ),
        HairstyleRecommendation(
          name: 'Bob Cut',
          description: 'Potongan klasik yang selalu cocok',
          imageUrl:
              'https://hips.hearstapps.com/hmg-prod/images/bob-haircuts-side-bangs-665a123b364ca.jpg?crop=1xw:0.833740234375xh;center,top',
        ),
      ],
    );
  }
}
