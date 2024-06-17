// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

class CollectionImage {
  final int id;
  final int collectionId;
  final File? image;

  CollectionImage({
    required this.id,
    required this.collectionId,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionId': collectionId,
      'image': image?.readAsBytesSync(),
    };
  }

  factory CollectionImage.fromMap(Map<String, dynamic> map) {
    return CollectionImage(
      id: map['id'],
      collectionId: map['collectionId'] ?? '',
      image: map['image'] == null ? null : File.fromRawPath(map['image']),
    );
  }

  CollectionImage copyWith({
    int? id,
    int? collectionId,
    File? image,
  }) {
    return CollectionImage(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      image: image ?? this.image,
    );
  }
}
