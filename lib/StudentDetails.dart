import 'package:flutter/material.dart';
import 'package:flutter_sqflite/model/DBHelper.dart';
import 'package:flutter_sqflite/model/Notes.dart';
import 'dart:async';
import 'package:flutter_sqflite/model/Student.dart';

class StudentDetails extends StatefulWidget {
  final Student student;
  StudentDetails(this.student);
  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  Future<List<Notes>> studentNotes;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  int currentNotesId;
  String title;
  String description;
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
      studentNotes = dbHelper.getNotesByStudent(widget.student.id);
    });
  }

  // Once the record is saved in DB, we are clearing textfield values
  clearForm() {
    titleController.text = '';
    descriptionController.text = '';
  }

  // Function to validate input form
  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        // Updating a record
        Notes note =
            Notes(currentNotesId, title, description, widget.student.id);
        dbHelper.updateNotes(note);
        setState(() {
          isUpdating = false;
        });
      } else {
        // Inserting a new record
        Notes note = Notes(null, title, description, widget.student.id);
        dbHelper.saveNotes(note);
      }
      clearForm();
      refreshList();
    }
  }

  // List of students with rows and columns widget
  SingleChildScrollView dataTable(List<Notes> studentNotes) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Expanded(
              child: Text(
                "Title",
                textAlign: TextAlign.left,
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                "OPTIONS",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        rows: studentNotes
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(
                    Text(e.title),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.mode_edit),
                          onPressed: () {
                            titleController.text = e.title;
                            descriptionController.text = e.description;
                            setState(() {
                              isUpdating = true;
                              currentNotesId = e.id;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () {
                            dbHelper.deleteNotes(e.id);
                            refreshList();
                          },
                        ),
                      ],
                    ),
                  ),
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
        future: studentNotes,
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
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
              ),
              validator: (val) => val.length == 0 ? "Enter Title" : null,
              onSaved: (val) => title = val,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
              ),
              validator: (val) => val.length == 0 ? "Enter notes" : null,
              onSaved: (val) => description = val,
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
                    clearForm();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Details"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              height: 550,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Details : ",
                    style: TextStyle(fontSize: 23),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    "  Name : " + widget.student.name,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "  Age : " + widget.student.age.toString(),
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "  Bio : " + widget.student.bio,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Notes: ",
                    style: TextStyle(fontSize: 22),
                  ),
                  form(),
                  list(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
