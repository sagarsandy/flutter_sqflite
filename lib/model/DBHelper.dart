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
  static const String DB_NAME = 'school_1.db';

  // Create tables
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
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }

  // DB on create method implementation
  _onCreate(Database db, int version) async {
    print('DB on create method called');
    var batch = db.batch();
    _createTables(batch);
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
        await dbClient.query(TABLE_STUDENT, columns: [ID, NAME, AGE]);

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
