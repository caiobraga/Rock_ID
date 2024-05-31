class Collection {
  final int collectionId;
  final String collectionName;
  final String description;

  Collection({
    required this.collectionId,
    required this.collectionName,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionName': collectionName,
      'description': description,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      collectionId: map['collectionId'] ?? 0,
      collectionName: map['collectionName'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
