import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:smart_beachmat_app/models/user.dart';

// Singleton.
class DatabaseProvider {
  static final DatabaseProvider _apiService = DatabaseProvider._();
  static Database _database;

  factory DatabaseProvider() {
    return _apiService;
  }

  // Constructor.
  DatabaseProvider._();

  static Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await openDatabase(
      join(await getDatabasesPath(), 'smart_beachmat_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(' +
              'id TEXT PRIMARY KEY,' +
              'name TEXT, skin_type INTEGER,' +
              'gender TEXT, dob TEXT,' +
              'is_owner INTEGER,' +
              'created_on TEXT)',
        );
      },
      version: 1,
    );
    return _database;
  }

  static Future<List<User>> getUsers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> map = await db.query('users');

    return List.generate(map.length, (i) {
      return User(
        id: map[i]['id'],
        name: map[i]['name'],
        skinType: int.parse(map[i]['skin_type']),
        gender: map[i]['gender'],
        dob: map[i]['dob'],
        isOwner: map[i]['is_owner'] == '1',
        createdOn: map[i]['created_on'],
      );
    });
  }

  static Future<void> addUser(User user) async {
    final Database db = await database;

    await db.insert(
      'users',
      {
        'id': user.id,
        'name': user.name,
        'skin_type': user.skinType,
        'gender': user.gender,
        'dob': user.dob,
        'is_owner': user.isOwner == true ? 1 : 0,
        'created_on': user.createdOn,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
