import 'package:flutter/material.dart';
import 'package:flutter_sqflite/model/DBHelper.dart';
import 'dart:async';

import 'package:flutter_sqflite/model/Student.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'SQFlite Complete Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Student>> students;
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  int currentUserId; // Used to determine current updating element for update
  String name;
  int age;
  String bio;
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  // Once the record is added, we will update the list with following function
  refreshList() {
    setState(() {
      students = dbHelper.getStudents();
    });
  }

  // Once the record is saved in DB, we are clearing textfield values
  clearName() {
    nameController.text = '';
    ageController.text = '';
    bioController.text = '';
  }

  // Function to validate input form
  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        // Updating a record
        Student stu = Student(currentUserId, name, age, bio);
        dbHelper.updateStudent(stu);
        setState(() {
          isUpdating = false;
        });
      } else {
        // Inserting a new record
        Student stud = Student(null, name, age, bio);
        dbHelper.saveStudent(stud);
      }
      clearName();
      refreshList();
    }
  }

  // List of students with rows and columns widget
  SingleChildScrollView dataTable(List<Student> students) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text("NAME"),
          ),
//          DataColumn(
//            label: Text("AGE"),
//          ),
          DataColumn(
            label: Text("BIO"),
          ),
          DataColumn(
            label: Text("EDIT"),
          ),
          DataColumn(
            label: Text("DELETE"),
          ),
        ],
        rows: students
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(
                    Text(e.name + "(" + e.age.toString() + ")"),
                  ),
//                  DataCell(
//                    Text(e.age.toString()),
//                  ),
                  DataCell(
                    Text(e.bio == null ? "--" : e.bio),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.mode_edit),
                      onPressed: () {
                        nameController.text = e.name;
                        ageController.text = e.age.toString();
                        bioController.text = e.bio;
                        setState(() {
                          isUpdating = true;
                          currentUserId = e.id;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.deleteStudent(e.id);
                        refreshList();
                      },
                    ),
                  )
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  // Creating list widget
  list() {
    return Expanded(
      child: FutureBuilder(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (snapshot.data == null || snapshot.data.length == 0) {
            return Text("No data found");
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  // Input form widget
  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
              ),
              validator: (val) => val.length == 0 ? "Enter Name" : null,
              onSaved: (val) => name = val,
            ),
            TextFormField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
              ),
              validator: (val) => val.length == 0 ? "Enter Age" : null,
              onSaved: (val) => age = int.parse(val),
            ),
            TextFormField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: "Bio",
              ),
              validator: (val) => val.length == 0 ? "Enter Bio" : null,
              onSaved: (val) => bio = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FlatButton(
                  onPressed: validate,
                  child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      isUpdating = false;
                    });
                    clearName();
                  },
                  child: Text('CANCEL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dbHelper.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            form(),
            list(),
          ],
        ),
      ),
    );
  }
}
