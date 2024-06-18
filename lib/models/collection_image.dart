import 'dart:typed_data';

class CollectionImage {
  final int id;
  final int collectionId;
  final Uint8List? image;

  CollectionImage({
    required this.id,
    required this.collectionId,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'image': image,
    };
  }

  factory CollectionImage.fromMap(Map<String, dynamic> map) {
    return CollectionImage(
      id: map['id'],
      collectionId: map['collectionId'] ?? '',
      image: map['image'] == null ? null : map['image'] as Uint8List,
    );
  }

  CollectionImage copyWith({
    int? id,
    int? collectionId,
    Uint8List? image,
  }) {
    return CollectionImage(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      image: image ?? this.image,
    );
  }
}
