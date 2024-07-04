class RockImage {
  final int id;
  final int rockId;
  final String? imagePath;

  RockImage({
    required this.id,
    required this.rockId,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'rockId': rockId,
      'imagePath': imagePath,
    };
  }

  factory RockImage.fromMap(Map<String, dynamic> map) {
    return RockImage(
      id: map['id'],
      rockId: map['rockId'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }

  RockImage copyWith({
    int? id,
    int? rockId,
    String? imagePath,
  }) {
    return RockImage(
      id: id ?? this.id,
      rockId: rockId ?? this.rockId,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
