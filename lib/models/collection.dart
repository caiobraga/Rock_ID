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
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      collectionId: map['collectionId'],
      collectionName: map['collectionName'],
      description: map['description'],
      number: map['number'] ?? '',
      dateAcquired: map['dateAcquired'],
      cost: map['cost'],
      locality: map['locality'],
      length: map['length'],
      width: map['width'],
      height: map['height'],
      notes: map['notes'],
    );
  }
}
