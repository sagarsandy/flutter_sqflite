class Student {
  int id;
  String name;
  int age;

  Student(
    this.id,
    this.name,
    this.age,
  );

  Map<dynamic, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
    };

    return map;
  }

  Student.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    age = map['age'];
  }
}
