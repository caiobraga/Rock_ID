import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rock_image.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';

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
      version: 30,
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
        rockCustomName TEXT,
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
        dateAcquired TEXT,
        cost REAL,
        locality TEXT,
        length REAL,
        width REAL,
        height REAL,
        notes TEXT,
        unitOfMeasurement TEXT,
        healthRisks TEXT,
        crystalSystem TEXT,
        colors TEXT,
        luster TEXT,
        diaphaneity TEXT,
        quimicalClassification TEXT,
        elementsListed TEXT,
        healingPropeties TEXT,
        formulation TEXT,
        meaning TEXT,
        howToSelect TEXT,
        types TEXT,
        uses TEXT,
        isAddedToCollection INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE rock_images(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        imagePath TEXT,
        FOREIGN KEY (rockId) REFERENCES rocks (rockId)
      )
    ''');

    await db.execute('''
      CREATE TABLE wishlist(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        imagePath TEXT,
        FOREIGN KEY (rockId) REFERENCES rocks (rockId)
      )
    ''');

    await db.execute('''
      CREATE TABLE snap_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rockId INTEGER,
        timestamp TEXT,
        scannedImagePath TEXT,
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

  Future<int?> getNumberOfRocksSaved() async {
    final db = await database;
    return firstIntValue(
      await db.query(
        'rocks',
        columns: ['COUNT(*)'],
        where: 'isAddedToCollection = true',
      ),
    );
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

  Future<void> removeRock(
    Rock rock, {
    bool isRemovingFromCollections = true,
  }) async {
    try {
      final db = await database;
      bool removeRock = false;

      if (isRemovingFromCollections) {
        rock = rock.copyWith(isAddedToCollection: false);
        await db.update(
          'rocks',
          rock.toMap(),
          where: 'rockId = ?',
          whereArgs: [rock.rockId],
        );
      }

      for (final defaultRock in Rock.rockList) {
        if (defaultRock.rockId == rock.rockId) {
          debugPrint('REMOVEU PEDRA!!!');
          removeRock = true;
          break;
        }
      }

      if (removeRock) {
        await db.delete(
          'rock_images',
          where: 'rockId = ?',
          whereArgs: [rock.rockId],
        );

        await db.delete(
          'rocks',
          where: 'rockId = ?',
          whereArgs: [rock.rockId],
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> rockExists(Rock rock) async {
    List<Rock> rocks = await findAllRocks();
    return rocks
        .where((element) =>
            element.rockId == rock.rockId && element.isAddedToCollection)
        .isNotEmpty;
  }

  // Functions for wishlist
  Future<void> addRockToWishlist(int rockId, String? imagePath) async {
    final db = await database;
    await db.insert(
      'wishlist',
      {
        'rockId': rockId,
        'imagePath': imagePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> wishlist() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wishlist');

    return List.generate(maps.length, (i) {
      return {
        'rockId': maps[i]['rockId'],
        'imagePath': maps[i]['imagePath'],
      };
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

  Future<void> addRockToSnapHistory(
      int rockId, String timestamp, String? scannedImagePath) async {
    final db = await database;
    await db.insert(
      'snap_history',
      {
        'rockId': rockId,
        'timestamp': timestamp,
        'scannedImagePath': scannedImagePath,
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
        'scannedImagePath': maps[i]['scannedImagePath'],
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

  Future<bool> imageExistsCollection(String imagePath) async {
    final db = await database;

    final images = await db.query(
      'rock_images',
      where: 'imagePath = ?',
      whereArgs: [imagePath],
    );

    return images.isNotEmpty;
  }

  Future<bool> imageExistsSnapHistory(String imagePath) async {
    final snaps = await snapHistory();
    for (final snapMap in snaps) {
      final scannedImagePath = snapMap['scannedImagePath'];
      if (scannedImagePath?.isNotEmpty == true &&
          scannedImagePath == imagePath) {
        return true;
      }
    }

    return false;
  }

  Future<bool> imageExistsLoved(String imagePath) async {
    final loved = await wishlist();
    for (final lovedMap in loved) {
      final lovedImagePath = lovedMap['imagePath'];
      if (lovedImagePath?.isNotEmpty == true && lovedImagePath == imagePath) {
        return true;
      }
    }

    return false;
  }

  Future<List<Rock>> incrementDefaultRockList(List<Rock> rockList) async {
    // Busca a lista de todas as rochas no banco de dados
    List<Rock> dbRockList = await findAllRocks();

    // Cria uma nova lista que é uma cópia da lista original passada como parâmetro
    final rockListIncremented = List<Rock>.from(rockList);

    // Filtra a lista de rochas do banco de dados, excluindo aquelas que já estão na lista original
    dbRockList = dbRockList
        .where((dbRock) => rockList
            .where((defaultRock) => defaultRock.rockId == dbRock.rockId)
            .isEmpty)
        .toList();

    // Adiciona as rochas filtradas à nova lista
    rockListIncremented.addAll(dbRockList);

    // Retorna a nova lista
    return rockListIncremented;
  }
}
