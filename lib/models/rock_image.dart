import 'dart:typed_data';

class RockImage {
  final int id;
  final int rockId;
  final Uint8List? image;

  RockImage({
    required this.id,
    required this.rockId,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'rockId': rockId,
      'image': image,
    };
  }

  factory RockImage.fromMap(Map<String, dynamic> map) {
    return RockImage(
      id: map['id'],
      rockId: map['rockId'] ?? '',
      image: map['image'] == null ? null : map['image'] as Uint8List,
    );
  }

  RockImage copyWith({
    int? id,
    int? rockId,
    Uint8List? image,
  }) {
    return RockImage(
      id: id ?? this.id,
      rockId: rockId ?? this.rockId,
      image: image ?? this.image,
    );
  }
}
