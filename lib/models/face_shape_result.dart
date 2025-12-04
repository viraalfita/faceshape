class FaceShapeResult {
  final String shape;
  final String description;
  final List<HairstyleRecommendation> recommendations;

  FaceShapeResult({
    required this.shape,
    required this.description,
    required this.recommendations,
  });

  factory FaceShapeResult.fromJson(Map<String, dynamic> json) {
    return FaceShapeResult(
      shape: json['shape'] ?? '',
      description: json['description'] ?? '',
      recommendations: (json['recommendations'] as List?)
          ?.map((e) => HairstyleRecommendation.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class HairstyleRecommendation {
  final String name;
  final String description;
  final String imageUrl;

  HairstyleRecommendation({
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory HairstyleRecommendation.fromJson(Map<String, dynamic> json) {
    return HairstyleRecommendation(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

