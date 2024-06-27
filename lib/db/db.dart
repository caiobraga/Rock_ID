import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rock_image.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 23,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rocks(
        rockId INTEGER PRIMARY KEY,
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
        isMagnetic INTEGER,
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
      CREATE TABLE rock_images(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        image BLOB,
        FOREIGN KEY (rockId) REFERENCES rocks (rockId)
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
    await db.execute('DROP TABLE IF EXISTS rock_images');
    await db.execute('DROP TABLE IF EXISTS wishlist');
    await db.execute('DROP TABLE IF EXISTS snap_history');
    await db.execute('DROP TABLE IF EXISTS rocks');

    // Recreate tables
    await _onCreate(db, newVersion);
  }

  //Functions for rocks
  Future<List<Rock>> findAllRocks() async {
    final db = await database;

    //getting list of rocks
    final List<Map<String, dynamic>> rockMap = await db.query('rocks');
    final rockList = rockMap.map((dbRock) => Rock.fromMap(dbRock)).toList();

    //getting list of rocks images
    final List<Map<String, dynamic>> rockImagesMap =
        await db.query('rock_images');
    final rockImagesList =
        rockImagesMap.map((dbRock) => RockImage.fromMap(dbRock)).toList();

    //returning rocks with it's images
    return rockList
        .map((rock) => rock.copyWith(
            rockImages: rockImagesList
                .where((rockImage) => rockImage.rockId == rock.rockId)
                .toList()))
        .toList();
  }

  Future<void> insertRock(Rock rock) async {
    final db = await database;
    await db.insert(
      'rocks',
      rock.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (final rockImage in rock.rockImages) {
      await db.insert(
        'rock_images',
        rockImage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> editRock(Rock rock) async {
    final db = await database;
    await db.update(
      'rocks',
      rock.toMap(),
      where: 'rockId = ?',
      whereArgs: [rock.rockId],
    );

    if (rock.rockImages.isNotEmpty) {
      final dbRockImages = await db
          .query('rock_images', where: 'rockId = ?', whereArgs: [rock.rockId]);

      if (dbRockImages.isNotEmpty) {
        await db.update(
          'rock_images',
          rock.rockImages.first.toMap(),
          where: 'rockId = ?',
          whereArgs: [rock.rockId],
        );

        return;
      }

      await db.insert('rock_images', rock.rockImages.first.toMap());
    }
  }

  Future<void> removeRock(int rockId) async {
    try {
      final db = await database;

      await db.delete(
        'rock_images',
        where: 'rockId = ?',
        whereArgs: [rockId],
      );

      await db.delete(
        'rocks',
        where: 'rockId = ?',
        whereArgs: [rockId],
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> rockExists(Rock rock) async {
    List<Rock> rocks = await findAllRocks();
    return rocks.where((element) => element.rockId == rock.rockId).isNotEmpty;
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
