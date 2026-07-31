import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bizzareapp/models/db_result.dart';

class DBHelper {
  static final DBHelper dbListing = DBHelper._init();

  static Database? _database;

  DBHelper._init();

  Future<Database> get listingDatabase async {
    if (_database != null) return _database!;
    _database = await _getDB();
    return _database!;
  }

  Future<Database> _getDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bizzare_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<DBResult> insertListing(Map<String, dynamic> listingDetailsRow) async {
    final db = await dbListing.listingDatabase;
    try {
      int listingId = await db.insert('listings', listingDetailsRow);
      if (listingId > 0) {
        return DBResult(
          isSuccess: true,
          message: "Listing inserted successfully with ID: $listingId",
          listingList: [],
        );
      } else {
        return DBResult(
          isSuccess: false,
          message: "Failed to insert listing",
          listingList: [],
        );
      }
    } catch (e) {
      return DBResult(isSuccess: false, message: "Error $e", listingList: []);
    }
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE listings(
      listingId INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      price REAL,
      category TEXT,
      condition TEXT,
      image TEXT
      )
      ''');
  }
}
