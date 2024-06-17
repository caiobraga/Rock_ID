// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_onboarding/models/collection_image.dart';

class Collection {
  final int collectionId;
  final String collectionName;
  final String description;
  final String number;
  final String dateAcquired;
  final double cost;
  final String locality;
  final double length;
  final double width;
  final double height;
  final String notes;
  final String unitOfMeasurement;
  final List<CollectionImage> collectionImagesFiles;

  Collection({
    required this.collectionId,
    required this.collectionName,
    required this.description,
    required this.number,
    required this.dateAcquired,
    required this.cost,
    required this.locality,
    required this.length,
    required this.width,
    required this.height,
    required this.notes,
    required this.unitOfMeasurement,
    this.collectionImagesFiles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionName': collectionName,
      'description': description,
      'number': number,
      'dateAcquired': dateAcquired,
      'cost': cost,
      'locality': locality,
      'length': length,
      'width': width,
      'height': height,
      'notes': notes,
      'unitOfMeasurement': unitOfMeasurement,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      collectionId: map['collectionId'],
      collectionName: map['collectionName'] ?? '',
      description: map['description'] ?? '',
      number: map['number'] ?? '',
      dateAcquired: map['dateAcquired'] ?? '',
      cost: map['cost'] ?? 0,
      locality: map['locality'] ?? '',
      length: map['length'] ?? 0,
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      notes: map['notes'] ?? '',
      unitOfMeasurement: map['unitOfMeasurement'] ?? '',
    );
  }

  Collection copyWith({
    int? collectionId,
    String? collectionName,
    String? description,
    String? number,
    String? dateAcquired,
    double? cost,
    String? locality,
    double? length,
    double? width,
    double? height,
    String? notes,
    String? unitOfMeasurement,
    List<CollectionImage>? collectionImagesFiles,
  }) {
    return Collection(
      collectionId: collectionId ?? this.collectionId,
      collectionName: collectionName ?? this.collectionName,
      description: description ?? this.description,
      number: number ?? this.number,
      dateAcquired: dateAcquired ?? this.dateAcquired,
      cost: cost ?? this.cost,
      locality: locality ?? this.locality,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      notes: notes ?? this.notes,
      unitOfMeasurement: unitOfMeasurement ?? this.unitOfMeasurement,
      collectionImagesFiles:
          collectionImagesFiles ?? this.collectionImagesFiles,
    );
  }
}
