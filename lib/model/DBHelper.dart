import 'dart:async';
import 'dart:io' as io;
import 'package:flutter_sqflite/model/Student.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database _db;
  static const String ID = 'id';
  static const String TABLE_STUDENT = 'student';
  static const String NAME = 'name';
  static const String AGE = 'age';
  static const String BIO = 'bio';
  static const String DB_NAME = 'school_1.db';

  // Create tables(This is initial or first version)
  void _createTables(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS student');
    batch.execute('''
            CREATE TABLE student (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name text not null,
              age integer not null
            )
        ''');
  }

  // Only runs when user is installing app for first time(assuming user doesn't have version one DB), this will directly create new schema with version 2
  void _createSchemaTablesV2(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS student');
    batch.execute('''
            CREATE TABLE student (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name text not null,
              age integer not null,
              bio text null
            )
        ''');
  }

  // Update schema from version one to version two
  void _updateSchemaTablesFromV1toV2(Batch batch) {
    batch.execute('ALTER TABLE student ADD bio TEXT null');
  }

  // Create single instance of DB
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  // Initializing DB
  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path,
        version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);

    return db;
  }

  // DB on create method implementation
  _onCreate(Database db, int version) async {
    print('DB on create method called');
    var batch = db.batch();
    // If the version is 1, then we need to call _createTables method. As we already did this previous commit, now directly creating new schema with v2
    _createSchemaTablesV2(batch);
    await batch.commit();
  }

  // DB on create method implementation, this method is new in second version.
  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DB on update method called');
    var batch = db.batch();
    if (oldVersion == 1) {
      _updateSchemaTablesFromV1toV2(batch);
    }
    await batch.commit();
  }

  // Function to save student in DB
  Future<Student> saveStudent(Student student) async {
    var dbClient = await db;
    student.id = await dbClient.insert(TABLE_STUDENT, student.toMap());

    return student;
  }

  // Function to fetch all students in DB
  Future<List<Student>> getStudents() async {
    var dbClient = await db;
    List<Map> maps =
        await dbClient.query(TABLE_STUDENT, columns: [ID, NAME, AGE, BIO]);

    List<Student> students = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        students.add(Student.fromMap(maps[i]));
      }
    }

    return students;
  }

  // Function to delete student from DB
  Future<int> deleteStudent(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(TABLE_STUDENT, where: '$ID = ?', whereArgs: [id]);
  }

  // Function to update student in DB
  Future<int> updateStudent(Student student) async {
    var dbClient = await db;
    return await dbClient.update(TABLE_STUDENT, student.toMap(),
        where: '$ID = ?', whereArgs: [student.id]);
  }

  // Function to close the DB connection
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
