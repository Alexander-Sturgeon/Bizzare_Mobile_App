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

    Future<DBResult> readAllListing() async {
    final db = await dbListing.listingDatabase;

    try {
      List<Map<String, dynamic>> listings = await db.query('listings');

      if (listings.isNotEmpty) {
        return DBResult(isSuccess: true, message: 'Listings retrieved successfully.', listingList: listings);
      } else {
        return DBResult(isSuccess: false, message: 'No listing found.', listingList: listings);
      }
    } catch (e) {
      return DBResult(isSuccess: false, message: "Error: $e", listingList: []);
    }
  }

//deletelisting that accesses the db with parameterized inputs to avoid sqli attacks, and returns a message depending on whether deletion was successful or not. 
Future<DBResult> deleteListing(int id) async {
      final db = await dbListing.listingDatabase;
      try{
        int rowsDeleted = await db.delete(
          'listings',
          where: 'listingId=?',
          whereArgs: [id],
        );

        if(rowsDeleted>0){
          return DBResult(isSuccess: true,message: "Listing Deleted Successfully", listingList:[]);
        }
        else{
          return DBResult(isSuccess: false,message: "No Matching Record Found", listingList: []);
        }
      }catch(e){
        return DBResult(isSuccess: false,message: "Error: $e", listingList: []);//returns if there is an issue encountered during deletion
      }
    }

    //structurely identical to the deleteListing db method, except the db.update method is invoked here instead of the delete. DBResult sent back in case of success or failure. 
    Future<DBResult> updateListing(int id, Map<String, dynamic> listingDetailsRow) async {
      final db = await dbListing.listingDatabase;
      try{
        int rowsAffected = await db.update(
          'listings',
          listingDetailsRow,
          where: 'listingId=?',
          whereArgs: [id],
        );
        if(rowsAffected>0){
          return DBResult(isSuccess: true, message: "Listing Updated Successfully", listingList: []);
        }else {
          return DBResult(isSuccess: false, message: "No Matching Record Found", listingList: []);
        }
      }catch(e){
        return DBResult(isSuccess: false, message: "Error: $e", listingList: []); 
      }
    }


}
