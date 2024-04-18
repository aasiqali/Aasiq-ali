import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_flutter_crud/JsonModels/users.dart';
import 'package:sqlite_flutter_crud/JsonModels/health_result.dart';

class DatabaseHelper {
  final databaseName = "notes.db";

  // Define the user table structure
  String users =
      "CREATE TABLE users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrName TEXT UNIQUE, usrPassword TEXT, usrEmail TEXT, usrPhoneNumber TEXT)";

  // Define the health check table structure
  String healthCheck =
      "CREATE TABLE health_check (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, healthStatus TEXT, checkUpDate TEXT, FOREIGN KEY(userId) REFERENCES users(usrId))";

  // Initialize the database
  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(users);
      await db.execute(healthCheck); // Create the health check table
    });
  }

  // Login method
  Future<bool> login(Users user) async {
    final Database db = await initDB();

    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrName = ? AND usrPassword = ?",
        [user.usrName, user.usrPassword]);

    return result.isNotEmpty;
  }

  // Sign up method with username uniqueness check
  Future<int> signup(Users user) async {
    final Database db = await initDB();

    try {
      return await db.insert('users', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        // Username already exists, return an error code (-1)
        return -1;
      } else {
        // Handle other exceptions or errors as needed
        throw e;
      }
    }
  }

  // Method to store health check-up results
  Future<int> storeHealthCheck(HealthCheck healthCheck) async {
    final Database db = await initDB();
    return await db.insert('health_check', healthCheck.toMap());
  }

  // Method to retrieve health checks from the database
  Future<List<HealthCheck>> getHealthChecks() async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query('health_check');
    return List.generate(maps.length, (i) {
      return HealthCheck(
        id: maps[i]['id'],
        userId: maps[i]['userId'],
        healthStatus: maps[i]['healthStatus'],
        checkUpDate: maps[i]['checkUpDate'],
      );
    });
  }
}
