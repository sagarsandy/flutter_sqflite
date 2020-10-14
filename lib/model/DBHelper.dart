import 'dart:async';
import 'dart:io' as io;
import 'package:flutter_sqflite/model/Notes.dart';
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
  static const String DB_NAME = 'school.db';
  static const String TABLE_NOTES = 'notes';
  static const String TITLE = 'title';
  static const String DESCRIPTION = 'description';

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

  // Second version of migration, if user doesn't have version one installed
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

  // Third version of migration, If user doesn't have version one and two
  void _createSchemaTablesV3(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS student');
    batch.execute('''
            CREATE TABLE student (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name text not null,
              age integer not null,
              bio text null
            )
        ''');
    batch.execute('DROP TABLE IF EXISTS notes');
    batch.execute('''
            CREATE TABLE notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title text not null,
              description text not null,
              student_id INTEGER NOT NULL,
              FOREIGN KEY (student_id) REFERENCES student (id) 
                ON DELETE NO ACTION ON UPDATE NO ACTION
            )
        ''');
  }

  // Update schema from version two to version three
  void _updateSchemaTablesFromV2toV3(Batch batch) {
    batch.execute('DROP TABLE IF EXISTS school');
    batch.execute('''
            CREATE TABLE notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title text not null,
              description text not null,
              student_id INTEGER NOT NULL,
              FOREIGN KEY (student_id) REFERENCES student (id) 
                ON DELETE NO ACTION ON UPDATE NO ACTION
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
    var db = await openDatabase(path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure);

    return db;
  }

  // Setting up FOREIGN KEY constraints
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // DB on create method implementation
  Future _onCreate(Database db, int version) async {
    print('DB on create method called');
    var batch = db.batch();
    // If the version is 1, then we need to call _createTables method.
    // If the version is 2, then we need to call _createSchemaTablesV2 method.
    _createSchemaTablesV3(batch);
    await batch.commit();
  }

  // DB on upgrade method implementation, this method is required from second version
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DB on update method called');
    var batch = db.batch();
    if (oldVersion == 2) {
      _updateSchemaTablesFromV2toV3(batch);
    } else if (oldVersion == 1) {
      _updateSchemaTablesFromV1toV2(batch);
    }
    await batch.commit();
  }

  // Student table related methods
  // Function to save student in DB
  Future<Student> saveStudent(Student student) async {
    var dbClient = await db;
    student.id = await dbClient.insert(TABLE_STUDENT, student.toMap());
    print(student.id);

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

  // Function to update student in DB
  Future<int> updateStudent(Student student) async {
    var dbClient = await db;
    return await dbClient.update(TABLE_STUDENT, student.toMap(),
        where: '$ID = ?', whereArgs: [student.id]);
  }

  // Function to delete student from DB
  Future<int> deleteStudent(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(TABLE_STUDENT, where: '$ID = ?', whereArgs: [id]);
  }

  // Function to save student notes in DB
  Future<Notes> saveNotes(Notes notes) async {
    var dbClient = await db;
    notes.id = await dbClient.insert(TABLE_NOTES, notes.toMap());
    print(notes.id);
    return notes;
  }

  // Notes table related methods
  // Function to fetch notes by student id
  Future<List<Notes>> getNotesByStudent(int student_id) async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE_NOTES,
        columns: [ID, TITLE, DESCRIPTION, 'student_id'],
        where: "student_id = ?",
        whereArgs: [student_id]);

    List<Notes> studentNotes = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        studentNotes.add(Notes.fromMap(maps[i]));
      }
    }

    return studentNotes;
  }

  // Function to delete student notes from DB
  Future<int> deleteNotes(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(TABLE_NOTES, where: '$ID = ?', whereArgs: [id]);
  }

  // Function to update student notes in DB
  Future<int> updateNotes(Notes notes) async {
    var dbClient = await db;
    return await dbClient.update(TABLE_NOTES, notes.toMap(),
        where: '$ID = ?', whereArgs: [notes.id]);
  }

  // Function to close the DB connection
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
