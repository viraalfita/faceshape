class FaceHistory {
  final int? id;
  final String shape;
  final String imagePath;
  final DateTime createdAt;

  FaceHistory({
    this.id,
    required this.shape,
    required this.imagePath,
    required this.createdAt,
  });

  FaceHistory copyWith({
    int? id,
    String? shape,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return FaceHistory(
      id: id ?? this.id,
      shape: shape ?? this.shape,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shape': shape,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FaceHistory.fromMap(Map<String, dynamic> map) {
    return FaceHistory(
      id: map['id'] as int?,
      shape: map['shape'] as String? ?? '',
      imagePath: map['image_path'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
