import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/models/collection.dart';
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
      version: 4,
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
        description TEXT
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTableIfNotExists(db, 'collections', '''
        CREATE TABLE collections(
          collectionId INTEGER PRIMARY KEY AUTOINCREMENT,
          collectionName TEXT,
          description TEXT
        )
      ''');

      await _createTableIfNotExists(db, 'rock_in_collection', '''
        CREATE TABLE rock_in_collection(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          rockId INTEGER,
          collectionId INTEGER,
          FOREIGN KEY (rockId) REFERENCES rocks (rockId),
          FOREIGN KEY (collectionId) REFERENCES collections (collectionId)
        )
      ''');
    }
    if (oldVersion < 4) {
      await _addColumnIfNotExists(db, 'rocks', 'formula', 'TEXT');
      await _addColumnIfNotExists(db, 'rocks', 'hardness', 'REAL');
      await _addColumnIfNotExists(db, 'rocks', 'color', 'TEXT');
      await _addColumnIfNotExists(db, 'rocks', 'isMagnetic', 'INTEGER');
    }
  }

  Future<void> _createTableIfNotExists(Database db, String tableName, String createTableQuery) async {
    try {
      await db.execute(createTableQuery);
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        print('Table $tableName already exists. Skipping creation.');
      } else {
        rethrow;
      }
    }
  }

  Future<void> _addColumnIfNotExists(Database db, String tableName, String columnName, String columnType) async {
    try {
      await db.rawQuery('SELECT $columnName FROM $tableName LIMIT 1');
    } catch (e) {
      if (e is DatabaseException) {
        await db.execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType');
      } else {
        rethrow;
      }
    }
  }

  Future<void> ensureSavedCollectionExists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'collections',
      where: 'collectionName = ?',
      whereArgs: ['Saved'],
    );

    if (maps.isEmpty) {
      await insertCollection(Collection(collectionId: 0, collectionName: 'Saved', description: 'Saved items'));
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

  Future<void> insertRock(Rock rock) async {
    final db = await database;
    await db.insert(
      'rocks',
      rock.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Ensure the "Saved" collection exists
    await ensureSavedCollectionExists();
    final int? savedCollectionId = await getSavedCollectionId();

    if (savedCollectionId != null) {
      // Add the rock to the "Saved" collection
      await addRockToCollection(rock.rockId, savedCollectionId);
    }
  }

  Future<List<Rock>> rocks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('rocks');

      return List.generate(maps.length, (i) {
        print(maps[i]);
        return Rock.fromMap(maps[i]);
      });
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Rock?> getRockById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rocks',
      where: 'rockId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Rock.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateRock(Rock rock) async {
    final db = await database;
    await db.update(
      'rocks',
      rock.toMap(),
      where: 'rockId = ?',
      whereArgs: [rock.rockId],
    );
  }

  Future<void> deleteRock(int id) async {
    final db = await database;
    await db.delete(
      'rocks',
      where: 'rockId = ?',
      whereArgs: [id],
    );
  }

  // Functions for collections

  Future<void> insertCollection(Collection collection) async {
    final db = await database;
    await db.insert(
      'collections',
      collection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Collection>> collections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('collections');

    return List.generate(maps.length, (i) {
      return Collection.fromMap(maps[i]);
    });
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
}
