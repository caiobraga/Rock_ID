import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/models/collection_image.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/rock_in_collection.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'rocks_database.db');

    return await openDatabase(
      path,
      version: 18,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rocks(
        rockId INTEGER PRIMARY KEY AUTOINCREMENT,
        price REAL,
        category TEXT,
        rockName TEXT,
        size TEXT,
        rating INTEGER,
        humidity REAL,
        temperature TEXT,
        imageURL TEXT,
        isFavorited INTEGER,
        description TEXT,
        isSelected INTEGER,
        formula TEXT,
        hardness REAL,
        color TEXT,
        isMagnetic INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE collections(
        collectionId INTEGER PRIMARY KEY AUTOINCREMENT,
        collectionName TEXT,
        description TEXT,
        number TEXT,
        dateAcquired TEXT,
        cost REAL,
        locality TEXT,
        length REAL,
        width REAL,
        height REAL,
        notes TEXT,
        unitOfMeasurement TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE collection_images(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image BLOB,
        collectionId INTEGER,
        CONSTRAINT fk_collections FOREIGN KEY (collectionId) REFERENCES collections(collectionId)
      )
    ''');

    await db.execute('''
      CREATE TABLE rock_in_collection(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        collectionId INTEGER,
        FOREIGN KEY (rockId) REFERENCES rocks (rockId),
        FOREIGN KEY (collectionId) REFERENCES collections (collectionId)
      )
    ''');

    await db.execute('''
      CREATE TABLE wishlist(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        FOREIGN KEY (rockId) REFERENCES rocks (rockId)
      )
    ''');

    await db.execute('''
      CREATE TABLE snap_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        timestamp TEXT,
        FOREIGN KEY (rockId) REFERENCES rocks (rockId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS rocks');
    await db.execute('DROP TABLE IF EXISTS collection_images');
    await db.execute('DROP TABLE IF EXISTS collections');
    await db.execute('DROP TABLE IF EXISTS rock_in_collection');
    await db.execute('DROP TABLE IF EXISTS wishlist');
    await db.execute('DROP TABLE IF EXISTS snap_history');

    // Recreate tables
    await _onCreate(db, newVersion);
  }

  Future<void> ensureSavedCollectionExists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'collections',
      where: 'collectionName = ?',
      whereArgs: ['Saved'],
    );

    if (maps.isEmpty) {
      await insertCollection(
        Collection(
          collectionId: 0,
          collectionName: 'Saved',
          description: 'Saved items',
          cost: 0,
          dateAcquired: DateTime.now().toIso8601String(),
          height: 0,
          length: 0,
          locality: '',
          notes: '',
          number: '',
          width: 0,
          unitOfMeasurement: 'cm',
        ),
      );
    }
  }

  Future<int?> getSavedCollectionId() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'collections',
      where: 'collectionName = ?',
      whereArgs: ['Saved'],
    );

    if (maps.isNotEmpty) {
      return maps.first['collectionId'] as int?;
    } else {
      return null;
    }
  }

  Future<void> insertCollection(Collection collection) async {
    try {
      final db = await database;
      final id = await db.insert(
        'collections',
        collection.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final collectionImagesWithCollectionId = collection.collectionImagesFiles
          .map((e) => e.copyWith(collectionId: id))
          .toList();

      for (var collectionImageFile in collectionImagesWithCollectionId) {
        final map = await collectionImageFile.toMap();
        await db.insert(
          'collection_images',
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('ERROR: $e');
    }
  }

  Future<List<Collection>> collections() async {
    final db = await database;
    final List<Map<String, dynamic>> collectionsMap =
        await db.query('collections');
    final List<Map<String, dynamic>> collectionImagesMap =
        await db.query('collection_images');
    final lstImages =
        collectionImagesMap.map((e) => CollectionImage.fromMap(e)).toList();

    final lstCollections =
        collectionsMap.map((e) => Collection.fromMap(e)).toList();

    final result = lstCollections
        .map((collection) => collection.copyWith(
            collectionImagesFiles: lstImages
                .where((element) =>
                    element.collectionId == collection.collectionId)
                .toList()))
        .toList();

    return result;
  }

  Future<void> updateCollection(Collection collection) async {
    final db = await database;
    await db.update(
      'collections',
      collection.toMap(),
      where: 'collectionId = ?',
      whereArgs: [collection.collectionId],
    );
  }

  Future<void> deleteCollection(int collectionId) async {
    final db = await database;
    await db.delete(
      'collections',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );
  }

  // Functions for rock_in_collection

  Future<void> addRockToCollection(int rockId, int collectionId) async {
    final db = await database;
    await db.insert(
      'rock_in_collection',
      {
        'rockId': rockId,
        'collectionId': collectionId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RockInCollection>> rocksInCollection(int collectionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rock_in_collection',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );

    return List.generate(maps.length, (i) {
      return RockInCollection.fromMap(maps[i]);
    });
  }

  Future<void> removeRockFromCollection(int rockId, int collectionId) async {
    final db = await database;
    await db.delete(
      'rock_in_collection',
      where: 'rockId = ? AND collectionId = ?',
      whereArgs: [rockId, collectionId],
    );
  }

  // Functions for wishlist

  Future<void> addRockToWishlist(int rockId) async {
    final db = await database;
    await db.insert(
      'wishlist',
      {
        'rockId': rockId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<int>> wishlist() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wishlist');

    return List.generate(maps.length, (i) {
      return maps[i]['rockId'] as int;
    });
  }

  Future<void> removeRockFromWishlist(int rockId) async {
    final db = await database;
    await db.delete(
      'wishlist',
      where: 'rockId = ?',
      whereArgs: [rockId],
    );
  }

  // Functions for snap_history

  Future<void> addRockToSnapHistory(int rockId, String timestamp) async {
    final db = await database;
    await db.insert(
      'snap_history',
      {
        'rockId': rockId,
        'timestamp': timestamp,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> snapHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('snap_history');

    return List.generate(maps.length, (i) {
      return {
        'rockId': maps[i]['rockId'],
        'timestamp': maps[i]['timestamp'],
      };
    });
  }

  Future<void> removeRockFromSnapHistory(int rockId) async {
    final db = await database;
    await db.delete(
      'snap_history',
      where: 'rockId = ?',
      whereArgs: [rockId],
    );
  }
}
