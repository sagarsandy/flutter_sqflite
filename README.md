# flutter_sqflite

A complete flutter sqlite example with sqflite

Which covers

- Sqflite: CRUD operation
- Sqflite: Migration
- Sqflite: Working with FKs and relations 


DBHelper.dart file changes as per the version

Version one:  
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
          version: 1,
          onCreate: _onCreate,
          );
      return db;
    }
    
  // DB on create method implementation
  
    
      Future _onCreate(Database db, int version) async {
        print('DB on create method called');
        var batch = db.batch();
        _createTables(batch);
        await batch.commit();
      }
      
While migrating to second version, we've added

    
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
    
   And Modified
   
   // Initializing DB
   
    
     initDb() async {
       io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
       String path = join(documentsDirectory.path, DB_NAME);
       var db = await openDatabase(path,
           version: 2,
           onCreate: _onCreate,
           onUpgrade: _onUpgrade,
         );
       return db;
     }
     
   // DB on create method implementation
   
    
       Future _onCreate(Database db, int version) async {
         print('DB on create method called');
         var batch = db.batch();
         _createSchemaTablesV2(batch);
         await batch.commit();
       }
     
   // DB on upgrade method implementation
      
    
    
       Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
         print('DB on update method called');
         var batch = db.batch();
         if (oldVersion == 1) {
           _updateSchemaTablesFromV1toV2(batch);
         }
         await batch.commit();
       }
   
While migrating to third version from second version, we've added
// Setting up FOREIGN KEY constraints
      
    
       
       Future _onConfigure(Database db) async {
         await db.execute('PRAGMA foreign_keys = ON');
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
        
   And modified
   
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
     
   
        
  // DB on create method implementation
     
    
       
    Future _onCreate(Database db, int version) async {
      print('DB on create method called');
      var batch = db.batch();
      _createSchemaTablesV3(batch);
      await batch.commit();
    }
    
  // DB on upgrade method implementation
     
    
       
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

Check commits for more info :)   


Flutter Info:
## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
