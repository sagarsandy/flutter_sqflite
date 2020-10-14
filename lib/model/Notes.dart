class Notes {
  int id;
  String title;
  String description;
  int student_id;

  Notes(
    this.id,
    this.title,
    this.description,
    this.student_id,
  );

  // Creating a map object to insert/update in database
  Map<dynamic, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'student_id': student_id,
    };

    return map;
  }

  // Creating notes object from database map object
  Notes.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
    student_id = map['student_id'];
  }
}
