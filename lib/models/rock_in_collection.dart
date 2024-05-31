class RockInCollection {
  final int id;
  final int rockId;
  final int collectionId;

  RockInCollection({
    required this.id,
    required this.rockId,
    required this.collectionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'rockId': rockId,
      'collectionId': collectionId,
    };
  }

  factory RockInCollection.fromMap(Map<String, dynamic> map) {
    return RockInCollection(
      id: map['id'] ?? 0,
      rockId: map['rockId'] ?? 0,
      collectionId: map['collectionId'] ?? 0,
    );
  }
}
